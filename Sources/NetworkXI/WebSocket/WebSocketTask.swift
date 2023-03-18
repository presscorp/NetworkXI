//
//  WebSocketTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public protocol WebSocketTask: AnyObject {

    var closeCode: URLSessionWebSocketTask.CloseCode { get }

    func receive() async throws -> URLSessionWebSocketTask.Message

    func send(_ message: URLSessionWebSocketTask.Message) async throws

    func sendPing(pongReceiveHandler: @escaping @Sendable (Error?) -> Void)

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension URLSessionWebSocketTask: WebSocketTask {}
