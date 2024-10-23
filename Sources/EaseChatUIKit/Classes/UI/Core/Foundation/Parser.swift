//
//  Parser.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/10/18.
//

import Foundation

struct AnyValue: Codable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Invalid value"))
        }
    }
}

struct Coder {
    static func decoder<T:Codable>(jsonString: String,classType:T.Type) -> T? {
        var result: T?
        do {
            if let data = jsonString.data(using: .utf8) {
                result = try JSONDecoder().decode(T.self, from: data)
            }
        } catch {
            consoleLogInfo("decoder failure:\(error.localizedDescription)", type: .debug)
        }
        return result
    }
    
    static func encoder<T:Codable>(classType: T) -> Dictionary<String,Any>? {
        var result: Dictionary<String,Any>?
        do {
            result = try JSONEncoder().encode(classType).chat.toDictionary()
        } catch {
            consoleLogInfo("encoder failure:\(error.localizedDescription)", type: .debug)
        }
        return result
    }
}
