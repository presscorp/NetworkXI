//
//  Data+extension.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public extension Data {

    var jsonString: String? { getJsonString() }

    var prettyJsonString: String? { getJsonString(pretty: true) }

    var dictionary: [String: Any]? {
        return try? JSONSerialization.jsonObject(with: self) as? [String: Any]
    }

    var utf8EncodedString: String? { String(data: self, encoding: .utf8) }

    var mimeType: String {
        var buffer = UInt8(0)
        copyBytes(to: &buffer, count: 1)

        switch buffer {
        case 0xFF: return "image/jpeg"
        case 0x89: return "image/png"
        case 0x47: return "image/gif"
        case 0x49, 0x4D: return "image/tiff"
        case 0x25: return "application/pdf"
        case 0xD0: return "application/vnd"
        case 0x46: return "text/plain"
        default: return "application/octet-stream"
        }
    }
}

fileprivate extension Data {

    func getJsonString(pretty: Bool = false) -> String? {
        var writingOptions: JSONSerialization.WritingOptions = [.fragmentsAllowed]
        if pretty {
            writingOptions = writingOptions.union([.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        }

        guard let jsonObject = try? JSONSerialization.jsonObject(with: self),
              let data = try? JSONSerialization.data(withJSONObject: jsonObject, options: writingOptions),
              var jsonString = String(data: data, encoding: .utf8) else {
            return utf8EncodedString
        }

        if pretty {
            jsonString = jsonString.replacingOccurrences(of: "\" : ", with: "\": ", options: .literal)
        }

        return jsonString
    }
}
