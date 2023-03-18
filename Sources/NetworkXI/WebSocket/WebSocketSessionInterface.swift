//
//  WebSocketSessionInterface.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

/// Interface between fundamental network session and its worker (web-socket service)
public protocol WebSocketSessionInterface: AnyObject {

    /// Common HTTP headers applied to connection made within this session
    var additionalHTTPHeaders: [String: String] { get set }

    /// Default SSL certificate handling for the challenge
    var defaultSSLChallengeEnabled: Bool { get set }

    /// SSL certificates stored as binary data
    var sslCertificates: [NSData] { get set }

    /// Indication of log printing of socket events into the console
    var loggingEnabled: Bool { get set }

    func resumedTask(with request: URLRequest) async throws -> WebSocketTask

    func send(string: String, via task: WebSocketTask) async throws

    func send(data: Data, via task: WebSocketTask) async throws

    func ping(via task: WebSocketTask) async throws

    @discardableResult
    func awaitDisconnect() async throws -> URLSessionWebSocketTask.CloseCode
}
