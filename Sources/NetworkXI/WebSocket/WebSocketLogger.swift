//
//  WebSocketLogger.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

class WebSocketLogger {

    private static var separatorLine: String { [String](repeating: "☰", count: 64).joined() }

    private static var title: String { "[ NetworkXI: WebSocket ]" }

    /// Web socket request logging
    static func log(request: URLRequest) {
        log(request)
    }

    static func logConnection(for request: URLRequest) {
        logConnectionStatus(request)
    }

    static func logDisconnection() {
        logDisconnectionStatus()
    }

    static func log(sentMessage message: String, error: Error? = nil) {
        log(action: "SENT", message: message, error: error)
    }

    static func log(sentData data: Data, error: Error? = nil) {
        log(action: "SENT", data: data, error: error)
    }

    static func log(receivedMessage message: String) {
        log(action: "RECEIVED", message: message, error: nil)
    }

    static func log(receivedData data: Data) {
        log(action: "RECEIVED", data: data, error: nil)
    }

    static func log(error: Error) {
        log(error)
    }

    static func logPingPong() {
        logPingPongAction()
    }

    private static func logConnectionStatus(_ request: URLRequest) {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"
        log += title + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"
        log += Self.getLog(for: request)
        log += "‣ STATUS: CONNECTED ✅\n\n"
        log += Self.separatorLine + "\n\n"

        print(log)
    }

    private static func logDisconnectionStatus() {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"
        log += title + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"
        log += "‣ STATUS: DISCONNECTED 🛑\n\n"
        log += Self.separatorLine + "\n\n"

        print(log)
    }

    private static func log(_ error: Error) {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"
        log += title + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"
        log += "‣ STATUS: ERROR ⚠️\n\n"
        log += "‣ REASON: " + error.localizedDescription + "\n\n"
        log += Self.separatorLine + "\n\n"

        print(log)
    }

    private static func logPingPongAction() {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"
        log += title + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"
        log += "‣ ACTION: PING-PONG \n\n"
        log += Self.separatorLine + "\n\n"

        print(log)
    }

    private static func log(_ request: URLRequest) {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"
        log += title + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"
        log += Self.getLog(for: request)
        log += "‣ STATUS: CONNECTING 🔗\n\n"
        log += Self.separatorLine + "\n\n"

        print(log)
    }

    private static func getLog(for request: URLRequest) -> String {
        var log = ""

        if let url = request.url {
            var urlString = url.absoluteString
            if urlString.last == "?" { urlString.removeLast() }
            log += "‣ URL: " + urlString + "\n\n"
        }

        if let headerFields = request.allHTTPHeaderFields,
           !headerFields.isEmpty,
           let data = try? JSONSerialization.data(withJSONObject: headerFields, options: [.prettyPrinted]),
           let jsonString = data.prettyJsonString {
            log += "‣ REQUEST HEADERS: " + jsonString + "\n\n"
        }

        return log
    }

    private static func log(action: String, message: String, error: Error?) {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"
        log += title + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"

        if let jsonDictionary = message.dictionary,
           let data = try? JSONSerialization.data(withJSONObject: jsonDictionary, options: [.prettyPrinted]),
           let jsonString = String(data: data, encoding: .utf8) {
            log += "‣ " + action + " MESSAGE: " + jsonString + "\n\n"
        } else {
            log += "‣ " + action + " MESSAGE: " + message + "\n\n"
        }

        if let error = error {
            log += "‣ STATUS: ERROR ⚠️\n\n"
            log += "‣ REASON: " + error.localizedDescription + "\n\n"
        }

        log += Self.separatorLine + "\n\n"

        print(log)
    }

    private static func log(action: String, data: Data, error: Error?) {
        var log = ""

        log += "\n" + Self.separatorLine + "\n\n"
        log += title + "\n\n"
        log += "‣ TIME: " + Date().description + "\n\n"

        if let jsonString = data.jsonString {
            log += "‣ " + action + ": " + jsonString + "\n\n"
        } else {
            log += "‣ " + action + ": " + data.base64EncodedString() + "\n\n"
        }

        if let error = error {
            log += "‣ STATUS: ERROR ⚠️\n\n"
            log += "‣ REASON: " + error.localizedDescription + "\n\n"
        }

        log += Self.separatorLine + "\n\n"

        print(log)
    }
}
