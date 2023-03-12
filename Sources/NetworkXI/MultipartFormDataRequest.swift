//
//  MultipartFormDataRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public typealias MultipartFormDataParams = (data: Data, name: String, fileName: String, mimeType: String)

public protocol MultipartFormDataRequest: NetworkRequest {

    var paramsArray: [MultipartFormDataParams] { get }

    var boundary: String { get }
}

public extension MultipartFormDataRequest {

    var method: RequestMethod { .POST }

    var encoding: RequestContentEncoding { fatalError() }

    static func generateBoundary() -> String { "Boundary-" + UUID().uuidString }

    var httpBody: Data? {
        var data = Data()

        parameters.forEach { key, value in
            guard let value = value as? CustomStringConvertible else { return }
            data.append("\r\n--" + boundary + "\r\n")
            data.append("Content-Disposition: form-data; name=\"" + key + "\"\r\n\r\n")
            data.append(value.description + "\r\n")
        }

        paramsArray.forEach { param in
            data.append("\r\n--" + boundary + "\r\n")
            data.append("Content-Disposition: form-data; name=\"" + param.name + "\"; filename=\"" + param.fileName)
            data.append("\"\r\nContent-Type: " + param.mimeType + "\r\n\r\n")
            data.append(param.data)
            data.append("\r\n")
        }

        data.append("--" + boundary + "--\r\n")

        return data as Data
    }
}

fileprivate extension Data {

    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8, allowLossyConversion: true) {
            append(data)
        }
    }
}
