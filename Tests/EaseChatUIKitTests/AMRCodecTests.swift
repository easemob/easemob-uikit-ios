import Foundation
import XCTest
@testable import EaseChatUIKit

final class AMRCodecTests: XCTestCase {
    func testNarrowbandRoundTripUsesEightKHzMonoPCM() throws {
        try assertRoundTrip(sampleRate: 8_000, magic: "#!AMR\n", encode: convert8khzWaveToAMR, decode: convertAMRNBToWave)
    }

    func testWidebandRoundTripUsesSixteenKHzMonoPCM() throws {
        try assertRoundTrip(sampleRate: 16_000, magic: "#!AMR-WB\n", encode: convert16khzWaveToAmr, decode: convertAMRWBToWave)
    }

    func testInvalidAudioIsRejected() {
        let invalid = Data("not an audio file".utf8)
        XCTAssertNil(readWaveStructure(data: invalid))
        XCTAssertNil(convert8khzWaveToAMR(wave: invalid))
        XCTAssertNil(convert16khzWaveToAmr(wave: invalid))
        XCTAssertNil(convertAMRNBToWave(data: invalid))
        XCTAssertNil(convertAMRWBToWave(data: invalid))
    }

    private func assertRoundTrip(
        sampleRate: UInt32,
        magic: String,
        encode: (Data) -> Data?,
        decode: (Data) -> Data?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        // Twenty complete 20 ms frames avoid padding/truncation ambiguity. A
        // deterministic tone verifies that the linked codec produces real PCM.
        let sampleCount = Int(sampleRate) * 2 / 5
        var pcm = Data(capacity: sampleCount * 2)
        for index in 0..<sampleCount {
            let phase = 2 * Double.pi * 440 * Double(index) / Double(sampleRate)
            var sample = Int16(sin(phase) * 12_000).littleEndian
            withUnsafeBytes(of: &sample) { pcm.append(contentsOf: $0) }
        }
        let wave = makeMono16BitWave(sampleRate: sampleRate, pcm: pcm)
        let source = try XCTUnwrap(readWaveStructure(data: wave), file: file, line: line)
        XCTAssertEqual(source.ckFmt.sampleRate, sampleRate, file: file, line: line)
        XCTAssertEqual(source.ckData.ckSize, UInt32(pcm.count), file: file, line: line)

        let encoded = try XCTUnwrap(encode(wave), file: file, line: line)
        let signature = Data(magic.utf8)
        XCTAssertTrue(encoded.starts(with: signature), file: file, line: line)
        XCTAssertGreaterThan(encoded.count, signature.count, file: file, line: line)
        XCTAssertLessThan(encoded.count, pcm.count, file: file, line: line)

        let decoded = try XCTUnwrap(decode(encoded), file: file, line: line)
        let result = try XCTUnwrap(readWaveStructure(data: decoded), file: file, line: line)
        XCTAssertEqual(result.ckFmt.sampleRate, sampleRate, file: file, line: line)
        XCTAssertEqual(result.ckFmt.audioFormat, 1, file: file, line: line)
        XCTAssertEqual(result.ckFmt.numChannels, 1, file: file, line: line)
        XCTAssertEqual(result.ckFmt.bitsPerSample, 16, file: file, line: line)
        XCTAssertEqual(result.ckData.ckSize, UInt32(pcm.count), file: file, line: line)
        XCTAssertEqual(decoded.count - result.dataOffset, pcm.count, file: file, line: line)
        XCTAssertTrue(decoded.dropFirst(result.dataOffset).contains { $0 != 0 }, file: file, line: line)
        // AMR is lossy; decoded bytes intentionally are not compared to input.
    }
}
