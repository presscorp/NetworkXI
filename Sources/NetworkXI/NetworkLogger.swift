//
//  NetworkLogger.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

class NetworkLogger {

    private static var separatorLine: String { [String](repeating: "☰", count: 64).joined() }

    private static func title(_ token: String) -> String { "[ NetworkXI: HTTP " + token + " ]" }

    /// Network request logging
    static func log(request: URLRequest) {
        log(request)
    }

    private static func log(_ request: URLRequest) {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"
        log += title("Request ➡️") + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"
        log += Self.getLog(for: request)
        log += Self.separatorLine + "\n\n"

        print(log)
    }

    private static func getLog(for request: URLRequest) -> String {
        var log = ""

        if let url = request.url,
           let method = request.httpMethod {
            var urlString = url.absoluteString
            if urlString.last == "?" { urlString.removeLast() }
            log += "‣ URL: " + urlString + "\n\n"
            log += "‣ METHOD: " + method + "\n\n"
        }

        if let headerFields = request.allHTTPHeaderFields,
           !headerFields.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: headerFields),
           let jsonString = data.prettyJsonString {
            log += "‣ REQUEST HEADERS: " + jsonString + "\n\n"
        }

        if let data = request.httpBody, !data.isEmpty {
            if let jsonString = data.prettyJsonString {
                log += "‣ REQUEST BODY: " + jsonString + "\n\n"
            } else {
                log += "‣ REQUEST BODY (FAILED TO PRINT)\n\n"
            }
        }

        return log
    }

    /// Network response logging
    static func log(request: URLRequest, response: HTTPURLResponse?, responseData: Data?, error: NSError?) {
        log(request, response, responseData, error)
    }

    private static func log(
        _ request: URLRequest,
        _ response: HTTPURLResponse?,
        _ responseData: Data?,
        _ error: NSError?
    ) {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"

        log += title("Response ⬅️") + "\n\n"
        
        log += "‣ TIME: " + Date().description + "\n\n"

        if let statusCode = response?.statusCode {
            let emoji: String
            if let response = response, 200..<300 ~= response.statusCode {
                emoji = "✅"
            } else {
                emoji = "⚠️"
            }
            log += "‣ STATUS CODE: " + statusCode.description + " " + emoji + "\n\n"
        }

        log += Self.getLog(for: request)

        if let headerFields = response?.allHeaderFields,
           !headerFields.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: headerFields),
           let jsonString = data.prettyJsonString {
            log += "‣ RESPONSE HEADERS: " + jsonString + "\n\n"
        }

        if let data = responseData, !data.isEmpty {
            if let jsonString = data.prettyJsonString {
                log += "‣ RESPONSE BODY: " + jsonString + "\n\n"
            } else {
                log += "‣ RESPONSE BODY (FAILED TO PRINT)\n\n"
            }
        }

        if let error = error {
            log += "‣ ERROR: " + error.localizedDescription + "\n\n"
        }
        log += Self.separatorLine + "\n\n"

        print(log)
    }
}
