//
//  AudioTools.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/29.
//

import AVFoundation

@objc open class AudioTools: NSObject {
    
    @objc public static let shared = AudioTools()
        
    private var stopPlayClosure: ((String) -> Void)?
    
    private var audioRecorder: AVAudioRecorder?
    
    private var audioPlayer: AVAudioPlayer?
    
    /// File that will be sent (the `.amr` after conversion). Never points at the preview WAV.
    public private(set) var audioFileURL: URL?

    /// Decoded WAV used only for local preview playback.
    private var previewFileURL: URL?
    
    @objc public func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            self.discardPreviewFile()
            
            let documentsDirectory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
            let chatFilesPath = documentsDirectory.appendingPathComponent("EaseChatUIKit/chatfiles/")
            
            if !FileManager.default.fileExists(atPath: chatFilesPath.path) {
                try FileManager.default.createDirectory(at: chatFilesPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            let audioFilename = chatFilesPath.appendingPathComponent("\(Int(Date().timeIntervalSince1970*1000)).wav")
            self.audioFileURL = audioFilename
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatLinearPCM),
                AVSampleRateKey: 8000.0,
                AVLinearPCMBitDepthKey: 16,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ] as [String : Any]
            
            self.audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            self.audioRecorder?.delegate = self
            self.audioRecorder?.prepareToRecord()
            self.audioRecorder?.record()
        } catch {
            consoleLogInfo("Failed to start recording: \(error.localizedDescription)", type: .error)
        }
    }
    
    @objc public func stopRecording() {
        self.audioRecorder?.stop()
        self.audioRecorder = nil
    }
    
    @objc public func playRecording(stopPlay: @escaping () -> Void) {
        guard let url = self.audioFileURL else { return }
        if AudioTools.canPlay(url: url) {
            self.play(fileURL: url)
            return
        }
        if let preview = self.previewFileURL, FileManager.default.fileExists(atPath: preview.path) {
            self.play(fileURL: preview)
            return
        }
        // Decode a preview copy next to the .amr; keep the .amr untouched so it is what gets sent.
        if let path = MediaConvertor.convertAMRToWAV(url: url, removeSource: false).1 {
            let preview = URL(fileURLWithPath: path)
            self.previewFileURL = preview
            self.play(fileURL: preview)
        } else {
            consoleLogInfo("Failed to decode recording for preview: \(url.path)", type: .error)
        }
    }

    private func play(fileURL: URL) {
        do {
            try preparePlaybackSession()
            self.audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.volume = 1
            self.audioPlayer?.play()
        } catch {
            consoleLogInfo("Failed to play recording: \(error.localizedDescription)", type: .error)
        }
    }

    /// Remove the preview WAV (if any). Call after the recording is sent or discarded.
    @objc public func discardPreviewFile() {
        if let preview = self.previewFileURL, FileManager.default.fileExists(atPath: preview.path) {
            try? FileManager.default.removeItem(at: preview)
        }
        self.previewFileURL = nil
    }
    
    @objc public func playRecording(path: String,stopPlay: @escaping (String) -> Void) {
        self.stopPlayClosure = stopPlay
        let fileURL = URL(fileURLWithPath: path)
        // Non-AMR payloads go straight to the system decoder; fix up a mismatched extension if needed.
        let playable = MediaConvertor.systemPlayableURL(for: fileURL) ?? fileURL
        do {
            try preparePlaybackSession()
            self.audioPlayer = try AVAudioPlayer(contentsOf: playable)
            self.audioPlayer?.delegate = self
            self.audioPlayer?.volume = 1
            self.audioPlayer?.play()
        } catch {
            consoleLogInfo("Failed to play recording: \(error.localizedDescription), format: \(MediaConvertor.detectAudioFormat(url: fileURL))", type: .error)
        }
    }

    private func preparePlaybackSession() throws {
        let session = AVAudioSession.sharedInstance()
        // `.defaultToSpeaker` is only valid with `.playAndRecord`; keep the same category used for recording so playback routes to the speaker.
        if session.category != .playAndRecord {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
        }
        try session.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    /// Whether the file can be handed to the system decoder as-is.
    /// Decided by content, not extension: AMR-NB/WB returns `false` (must be decoded with the bundled codec first);
    /// WAV / MP3 / AAC / M4A / CAF / AIFF / FLAC return `true` when `AVAudioPlayer` can open them.
    @objc static public func canPlay(url: URL) -> Bool {
        let format = MediaConvertor.detectAudioFormat(url: url)
        if format.needsAMRCodec {
            return false
        }
        guard format.isSystemPlayable else {
            // Unknown header: let the system have a go (e.g. exotic containers), otherwise not playable.
            return (try? AVAudioPlayer(contentsOf: url)) != nil
        }
        let playable = MediaConvertor.systemPlayableURL(for: url) ?? url
        return (try? AVAudioPlayer(contentsOf: playable)) != nil
    }

    /// Content-sniffed audio format of a file.
    static public func audioFormat(of url: URL) -> MediaConvertor.AudioPayloadFormat {
        MediaConvertor.detectAudioFormat(url: url)
    }
    
    @objc public func stopPlaying() {
        self.audioPlayer?.stop()
        self.audioPlayer = nil
    }
    
}

extension AudioTools: AVAudioPlayerDelegate,AVAudioRecorderDelegate {
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            self.stopPlayClosure?(player.url?.path ?? "")
        } else {
            consoleLogInfo("play audio error", type: .error)
        }
    }
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            let tuple = MediaConvertor.convertWAVToAMR(url: recorder.url)
            if let path = tuple.1 {
                print("file exist result:\(FileManager.default.fileExists(atPath: path))")
                AudioTools.shared.audioFileURL = URL(fileURLWithPath: path)
            }
        } else {
            consoleLogInfo("record audio error", type: .error)
        }
    }
}

