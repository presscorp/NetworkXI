//
//  WebSocketService.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

/// Base service for web-socket message exchange
public protocol WebSocketService: AsyncSequence
where Element == URLSessionWebSocketTask.Message, AsyncIterator == WebSocketStream.Iterator {

    typealias WebSocketStream = AsyncThrowingStream<Element, Error>

    ///  Establishing web-socket connection
    /// - Parameter request: Web-socket request that describes all needed details
    func connect(using request: WebSocketRequest) async throws

    /// Disconnecting the socket
    func disconnect() async throws

    /// Send binary data to the server
    /// - Parameter data: Binary data
    func send(data: Data) async throws

    /// Send plain text message
    /// - Parameter string: text message
    func send(string: String) async throws

    ///  Send ping to the server
    func ping() async throws
}
