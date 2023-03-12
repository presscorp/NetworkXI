//
//  WebSocketTask.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public protocol WebSocketTask: AnyObject {

    var originalRequest: URLRequest? { get }

    func resume()

    func receive(completionHandler: @escaping (Result<URLSessionWebSocketTask.Message, Error>) -> Void)

    func send(_ message: URLSessionWebSocketTask.Message, completionHandler: @escaping (Error?) -> Void)

    func sendPing(pongReceiveHandler: @escaping @Sendable (Error?) -> Void)

    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
}

extension URLSessionWebSocketTask: WebSocketTask {}
