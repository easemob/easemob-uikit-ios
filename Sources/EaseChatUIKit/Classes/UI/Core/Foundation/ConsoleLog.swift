//
//  ConsoleLog.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2020/12/17.
//

import Foundation

public enum consoleLogType : String {
    case error   = "ERROR"
    case waring  = "WARING"
    case info    = "INFO";
    case debug   = "DEBUG"
    case mark    = "MARK"
    case test    = "TEST"
}

///  Log
/// - Parameters:
///   - message: object that you want to print
///   - type: print type
///   - file: fileName
///   - function: functionName
///   - line: print line
public func consoleLogInfo <T> (
    _ message : T,
    type : consoleLogType,
    file : StaticString = #file,
    function : StaticString = #function,
    line : UInt = #line
) {
   consoleLog(message, type: type, file : file, function: function, line: line)
}

private func consoleLog<T> (
    _ message : T,
    type : consoleLogType,
    file : StaticString = #file,
    function : StaticString = #function,
    line : UInt = #line
){
    #if DEBUG
    let time = DateFormatter()
    time.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    let timeString = time.string(from: Date())
    let fileName = (file.description as NSString).lastPathComponent
    let functionName = (function.description as NSString).lastPathComponent
    debugPrint("\n\(timeString) \(type.rawValue) \(fileName):\(line) EaseChatUIKit Log:\(message) function Name:\(functionName)")
    #else
    if type == .error {
        Log.saveLog(" EaseChatUIKit Log:\(message) \n",file: file,function: function,line: line)
    }
    #endif
}

final class Log {
    static let logFileURL: URL = {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectoryURL.appendingPathComponent("EaseChatUIKit\(ChatUIKit_VERSION).log")
    }()
    
    static func saveLog(_ message: String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
        let fileName = (file.description as NSString).lastPathComponent
        let functionName = (function.description as NSString).lastPathComponent
        let logMessage = "[\(sourceFileName(fileName))]:\(functionName), line \(line) - \(message)"
        writeToFile(logMessage)
    }
    
    private static func sourceFileName(_ filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    
    private static func writeToFile(_ message: String) {
        let fileHandle = try? FileHandle(forWritingTo: logFileURL)
        if fileHandle == nil {
            try? message.write(to: logFileURL, atomically: false, encoding: .utf8)
        } else {
            let data = message.data(using: .utf8)!
            fileHandle?.seekToEndOfFile()
            fileHandle?.write(data)
            fileHandle?.closeFile()
        }
    }
}
