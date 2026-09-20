//
//  MediaConvertor.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/12/6.
//

import UIKit
import AVFoundation
import Photos
//import AssetsLibrary
import AVFAudio

open class MediaConvertor: NSObject {

    static public func videoConvertor(videoURL: URL) -> URL? {
        var url: URL? = nil
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
        if compatiblePresets.contains(AVAssetExportPresetHighestQuality) {
            let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)
            let filePath = "\(self.filePath())/\(Int(Date().timeIntervalSince1970))\(1000).mp4"
            url = URL(fileURLWithPath: filePath)
            exportSession?.outputURL = url
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.outputFileType = AVFileType.mp4
            
            let wait = DispatchSemaphore(value: 0)
            exportSession?.exportAsynchronously {
                switch exportSession?.status {
                case .failed:
                    consoleLogInfo("failed, error: \(exportSession?.error?.localizedDescription ?? "")", type: .error)
                case .cancelled:
                    consoleLogInfo("cancelled", type: .debug)
                case .completed:
                    consoleLogInfo("completed", type: .debug)
                default:
                    break
                }
                wait.signal()
            }
            wait.wait()
            
        }

        return url
    }
    
    static public func filePath() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        path = (path as NSString).appendingPathComponent("appdata/chatbuffer/")
        if !FileManager.default.fileExists(atPath: path) {
            try? FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        }

        return path
    }
    
    static func firstFrame(from videoPath: String, completion: @escaping (UIImage?) -> Void) {
        let videoAsset = AVURLAsset(url: URL(fileURLWithPath: videoPath))
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
        imageGenerator.appliesPreferredTrackTransform = true
        let inTime = CMTime(seconds: 1, preferredTimescale: 60)
        let timeValue = NSValue(time: inTime)
        imageGenerator.generateCGImagesAsynchronously(forTimes: [timeValue]) { time1, image, time2, result, error in
            switch (result) {
            case .cancelled:
                consoleLogInfo("generate first frame cancelled", type: .error)
                completion(nil)
            case .failed:
                consoleLogInfo("generate first frame failed", type: .error)
                completion(nil)
            case .succeeded:
                if let firstFrame = image {
                    let thumbnailImage = UIImage(cgImage: firstFrame)
                    videoAsset.cancelLoading()
                    completion(thumbnailImage)
                } else {
                    completion(nil)
                }
            @unknown default:
                fatalError()
            }
        }
    }
    
    static func writeFile(to path: String,data: Data) {
        if FileManager.default.fileExists(atPath: path) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                consoleLogInfo("write file first remove error:\(error.localizedDescription )", type: .error)
            }
        }
        do {
            try data.write(to: URL(fileURLWithPath: path))
        } catch {
            consoleLogInfo("write file error:\(error.localizedDescription )", type: .error)
        }
    }
    
    // MARK: - Audio payload detection

    /// Audio container detected from the file header (not the extension).
    /// AMR variants must go through the bundled codec; everything else is handed to the system decoder (`AVAudioPlayer`).
    public enum AudioPayloadFormat: Equatable {
        case amrNB
        case amrWB
        case wav
        case mp3
        case aac      // ADTS stream
        case m4a      // MPEG-4 container (AAC/ALAC)
        case caf
        case aiff
        case flac
        case ogg
        case unknown

        /// Whether the bundled AMR codec is required to decode this payload.
        public var needsAMRCodec: Bool {
            self == .amrNB || self == .amrWB
        }

        /// Whether the payload can be handed to `AVAudioPlayer` directly.
        public var isSystemPlayable: Bool {
            switch self {
            case .wav, .mp3, .aac, .m4a, .caf, .aiff, .flac:
                return true
            case .amrNB, .amrWB, .ogg, .unknown:
                return false
            }
        }

        /// Canonical file extension for the detected payload.
        public var fileExtension: String? {
            switch self {
            case .amrNB, .amrWB: return "amr"
            case .wav: return "wav"
            case .mp3: return "mp3"
            case .aac: return "aac"
            case .m4a: return "m4a"
            case .caf: return "caf"
            case .aiff: return "aiff"
            case .flac: return "flac"
            case .ogg: return "ogg"
            case .unknown: return nil
            }
        }
    }

    static let amrNBMagic = "#!AMR\n".data(using: .ascii)!
    static let amrWBMagic = "#!AMR-WB\n".data(using: .ascii)!

    /// Detect the audio container from the leading bytes. Needs at least 12 bytes for reliable detection.
    static func detectAudioFormat(_ head: Data) -> AudioPayloadFormat {
        if head.starts(with: amrWBMagic) { return .amrWB }
        if head.starts(with: amrNBMagic) { return .amrNB }
        guard head.count >= 4 else { return .unknown }
        let bytes = [UInt8](head.prefix(12))
        func ascii(_ range: Range<Int>) -> String {
            guard bytes.count >= range.upperBound else { return "" }
            return String(bytes: bytes[range], encoding: .ascii) ?? ""
        }
        let tag4 = ascii(0..<4)
        if tag4 == "RIFF", ascii(8..<12) == "WAVE" { return .wav }
        if tag4 == "FORM", ["AIFF", "AIFC"].contains(ascii(8..<12)) { return .aiff }
        if tag4 == "caff" { return .caf }
        if tag4 == "fLaC" { return .flac }
        if tag4 == "OggS" { return .ogg }
        if bytes.count >= 8, ascii(4..<8) == "ftyp" { return .m4a }
        if tag4.hasPrefix("ID3") { return .mp3 }
        // ADTS AAC: 12-bit sync 0xFFF, layer bits == 00
        if bytes[0] == 0xFF, (bytes[1] & 0xF6) == 0xF0 { return .aac }
        // MPEG audio frame sync 0xFFE/0xFFF with a valid layer (MP3: layer III => bits 01)
        if bytes[0] == 0xFF, (bytes[1] & 0xE0) == 0xE0, (bytes[1] & 0x06) != 0 { return .mp3 }
        return .unknown
    }

    /// Detect the audio container of a file by reading only its header.
    static func detectAudioFormat(url: URL) -> AudioPayloadFormat {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return .unknown }
        defer { try? handle.close() }
        return detectAudioFormat(handle.readData(ofLength: 12))
    }

    static func isAMR(_ data: Data) -> Bool {
        detectAudioFormat(data).needsAMRCodec
    }

    static func isRIFFWave(_ data: Data) -> Bool {
        detectAudioFormat(data) == .wav
    }

    /// Resolve a URL that `AVAudioPlayer` can open for a non-AMR payload.
    /// When the extension disagrees with the real container (e.g. an MP3 stored as `xxx.amr`), a sibling file with the
    /// correct extension is created so the system decoder gets a proper type hint. Returns `nil` for AMR/unknown payloads.
    static func systemPlayableURL(for url: URL) -> URL? {
        let format = detectAudioFormat(url: url)
        guard format.isSystemPlayable, let ext = format.fileExtension else { return nil }
        if url.pathExtension.lowercased() == ext || (format == .aiff && url.pathExtension.lowercased() == "aif") {
            return url
        }
        let fixed = url.deletingPathExtension().appendingPathExtension(ext)
        if !FileManager.default.fileExists(atPath: fixed.path) {
            do {
                try FileManager.default.copyItem(at: url, to: fixed)
            } catch {
                consoleLogInfo("systemPlayableURL copy failed: \(error.localizedDescription)", type: .error)
                return url
            }
        }
        return fixed
    }

    /// Decode an AMR file to WAV next to it (`foo.amr` -> `foo.wav`) using the bundled codec.
    /// Non-AMR payloads are not decoded here: WAV is passed through, other system formats are copied with a proper
    /// extension, and unknown payloads fail with a log line.
    /// - Parameter removeSource: delete the source after a successful conversion. Pass `false` when the source still needs to be sent.
    static func convertAMRToWAV(url: URL, removeSource: Bool = true) -> (Data?,String?) {
        do {
            let data = try Data(contentsOf: url)
            let format = detectAudioFormat(data)
            let wave: Data?
            switch format {
            case .amrWB:
                wave = convertAMRWBToWave(data: data)
            case .amrNB:
                wave = convertAMRNBToWave(data: data)
            case .wav:
                wave = data
            case .unknown, .ogg:
                consoleLogInfo("convertAMRToWAV: unsupported audio payload at \(url.path), head=\(Array(data.prefix(8)))", type: .error)
                wave = nil
            default:
                // Already a system-decodable format; no AMR decoding needed.
                if let playable = systemPlayableURL(for: url) {
                    return (data, playable.path)
                }
                wave = nil
            }
            guard let wave else {
                return (nil,nil)
            }
            let wavURL = url.deletingPathExtension().appendingPathExtension("wav")
            if wavURL != url {
                try wave.write(to: wavURL)
                if removeSource, FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
            }
            return (wave,wavURL.path)
        } catch {
            consoleLogInfo("convertAMRToWAV failed: \(error.localizedDescription)", type: .error)
            return (nil,nil)
        }
        
    }
    
    static func convertWAVToAMR(url: URL) -> (Data?,String?) {
        do {
            let data = try Data(contentsOf: url)
            let path = url.path
            let filePath = (path.components(separatedBy: ".").first ?? String(url.path.dropLast(4)))+".amr"
            // Recorder WAV often contains FLLR filler; prefer AVAudioFile samples first.
            var amr: Data?
            if let normalized = canonicalPCMWave(from: url) {
                amr = convert8khzWaveToAMR(wave: normalized)
            }
            if amr == nil {
                amr = convert8khzWaveToAMR(wave: data)
            }
            guard let amr else {
                consoleLogInfo("convert wav to amr failed, wav size: \(data.count)", type: .error)
                return (nil,nil)
            }
            try amr.write(to: URL(fileURLWithPath: filePath))
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            }
            return (amr,filePath)
        } catch {
            return (nil,nil)
        }
        
    }

    /// Rebuild a canonical 8kHz mono 16-bit WAV from whatever AVAudioRecorder actually wrote.
    static func canonicalPCMWave(from url: URL) -> Data? {
        do {
            let audioFile = try AVAudioFile(forReading: url)
            let srcFormat = audioFile.processingFormat
            let srcFrames = AVAudioFrameCount(audioFile.length)
            guard srcFrames > 0,
                  let srcBuffer = AVAudioPCMBuffer(pcmFormat: srcFormat, frameCapacity: srcFrames) else {
                return nil
            }
            try audioFile.read(into: srcBuffer)
            srcBuffer.frameLength = srcFrames

            guard let pcm = int16Mono8kPCM(from: srcBuffer, format: srcFormat), !pcm.isEmpty else {
                return nil
            }
            return makeMono16BitWave(sampleRate: 8000, pcm: pcm)
        } catch {
            consoleLogInfo("normalize wav failed: \(error.localizedDescription)", type: .error)
            return nil
        }
    }

    static func int16Mono8kPCM(from srcBuffer: AVAudioPCMBuffer, format srcFormat: AVAudioFormat) -> Data? {
        if srcFormat.sampleRate == 8000, srcFormat.channelCount == 1 {
            if srcFormat.commonFormat == .pcmFormatInt16, let channel = srcBuffer.int16ChannelData {
                return Data(bytes: channel[0], count: Int(srcBuffer.frameLength) * MemoryLayout<Int16>.size)
            }
            if let floats = srcBuffer.floatChannelData {
                let count = Int(srcBuffer.frameLength)
                var samples = [Int16](repeating: 0, count: count)
                for i in 0..<count {
                    let clipped = max(-1.0, min(1.0, floats[0][i]))
                    samples[i] = Int16(clipped * 32767.0)
                }
                return samples.withUnsafeBufferPointer { Data(buffer: $0) }
            }
        }

        guard let dstFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 8000, channels: 1, interleaved: true),
              let converter = AVAudioConverter(from: srcFormat, to: dstFormat) else {
            return nil
        }
        let dstFrames = AVAudioFrameCount(max(ceil(Double(srcBuffer.frameLength) * 8000.0 / srcFormat.sampleRate), 1))
        guard let dstBuffer = AVAudioPCMBuffer(pcmFormat: dstFormat, frameCapacity: dstFrames) else {
            return nil
        }

        var pcm = Data()
        var providedInput = false
        var finished = false
        while !finished {
            dstBuffer.frameLength = 0
            var convertError: NSError?
            let status = converter.convert(to: dstBuffer, error: &convertError) { _, status in
                if providedInput {
                    status.pointee = .endOfStream
                    return nil
                }
                providedInput = true
                status.pointee = .haveData
                return srcBuffer
            }
            if convertError != nil {
                return nil
            }
            if dstBuffer.frameLength > 0, let channel = dstBuffer.int16ChannelData {
                pcm.append(Data(bytes: channel[0], count: Int(dstBuffer.frameLength) * MemoryLayout<Int16>.size))
            }
            if status == .error {
                return nil
            }
            if status == .endOfStream || (providedInput && dstBuffer.frameLength == 0) {
                finished = true
            }
        }
        return pcm.isEmpty ? nil : pcm
    }
    
//    static func detectAudioFormat(data: Data) {
//        // 将二进制数据转换为AVAudioPCMBuffer对象
//        let audioBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 8000, channels: 1, interleaved: <#Bool#>)!, frameCapacity: UInt32(data.count) / 4)!
//        audioBuffer.frameLength = audioBuffer.frameCapacity
//        
//        // 将二进制数据拷贝到AVAudioPCMBuffer中
//        let audioBufferChannelData = audioBuffer.floatChannelData
//        data.withUnsafeBytes { (bufferPointer: UnsafeRawBufferPointer) in
//            let floatBufferPointer = bufferPointer.bindMemory(to: Float.self)
//            let audioBufferData = floatBufferPointer.baseAddress!
//            for channel in 0..<Int(audioBuffer.format.channelCount) {
//                let audioBufferChannelDataPtr = audioBufferChannelData?[channel]
//                memcpy(audioBufferChannelDataPtr, audioBufferData, data.count)
//            }
//        }
//        
//        // 获取音频数据的格式
//        let audioFormat = audioBuffer.format
//        
//        // 输出音频数据的格式信息
//        print("Sample Rate: \(audioFormat.sampleRate)")
//        print("Channel Count: \(audioFormat.channelCount)")
//        print("Bits Per Channel: \(audioFormat.streamDescription.pointee.mBitsPerChannel)")
//        print("Bytes Per Frame: \(audioFormat.streamDescription.pointee.mBytesPerFrame)")
//        print("Frames Per Packet: \(audioFormat.streamDescription.pointee.mFramesPerPacket)")
//    }

    //检测录音权限
    static func checkRecordPermission() -> Bool {
        var permission = false
        let session = AVAudioSession.sharedInstance()
        if #available(iOS 17.0, *) {
            permission = AVAudioApplication.shared.recordPermission == .granted
        } else {
            permission = session.recordPermission == .granted
        }
        return permission
    }
    
    //请求录音权限
    static func requestRecordPermission(completion: @escaping (Bool) -> Void) {
        let session = AVAudioSession.sharedInstance()
        if #available(iOS 17.0, *) {
            AVAudioApplication.requestRecordPermission { (granted) in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }

        } else {
            session.requestRecordPermission { (granted) in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    }
    
}
