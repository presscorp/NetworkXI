//
//  ConsoleLogger.swift
//  
//
//  Created by Zhalgas Baibatyr on 03.06.2023.
//

import Foundation

public class ConsoleLogger {

    public init() {}

    private var separatorLine: String { [String](repeating: "☰", count: 64).joined() }

    private func title(_ token: String) -> String { "[ NetworkXI: HTTP " + token + " ]" }

    private func getLog(for request: URLRequest) -> String {
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
}

extension ConsoleLogger: NetworkLogger {

        /// Network request logging
        public func log(request: URLRequest) {
            var log = ""

            log += "\n" + separatorLine + "\n\n"
            log += title("Request ➡️") + "\n\n"
            log += "‣ TIME: " + Date().description + "\n\n"
            log += getLog(for: request)
            log += separatorLine + "\n\n"

            print(log)
        }

        /// Network response logging
        public func log(
            request: URLRequest,
            response: HTTPURLResponse?,
            responseData: Data?,
            error: Error?,
            responseIsCached: Bool,
            responseIsMocked: Bool
        ) {
        var log = ""

        log += "\n" + separatorLine + "\n\n"

        let titlePrefix = responseIsCached ? "Cached " : (responseIsMocked ? "Mocked " : "")

        log += title(titlePrefix + "Response ⬅️") + "\n\n"

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

        log += getLog(for: request)

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

        if let error = error as? NetworkError {
            log += "‣ ERROR: " + error.rawValue + "\n\n"
        } else if let error {
            log += "‣ ERROR: " + error.localizedDescription + "\n\n"
        }
        log += separatorLine + "\n\n"

        print(log)
    }
}
