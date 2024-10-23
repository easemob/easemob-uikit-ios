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

final class MediaConvertor: NSObject {

    static func videoConvertor(videoURL: URL) -> URL? {
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
    
    static func filePath() -> String {
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
    
    static func convertAMRToWAV(url: URL) -> (Data?,String?) {
        do {
            let data = try Data(contentsOf: url)
            let path = url.path
            let filePath = (path.components(separatedBy: ".").first ?? String(url.path.dropLast(4)))+".wav"
            let wave = convertAMRWBToWave(data: data)
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            }
            try wave?.write(to: URL(fileURLWithPath: filePath))
            return (wave,filePath)
        } catch {
            return (nil,nil)
        }
        
    }
    
    static func convertWAVToAMR(url: URL) -> (Data?,String?) {
        do {
            let data = try Data(contentsOf: url)
            let path = url.path
            let filePath = (path.components(separatedBy: ".").first ?? String(url.path.dropLast(4)))+".amr"
            let wave = convert8khzWaveToAMR(wave: data)
            if FileManager.default.fileExists(atPath: path) {
                try FileManager.default.removeItem(atPath: path)
            }
            try wave?.write(to: URL(fileURLWithPath: filePath))
            return (wave,filePath)
        } catch {
            return (nil,nil)
        }
        
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
