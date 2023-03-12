//
//  WebSocketService.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

/// Base service for web-socket message exchange
public protocol WebSocketService: AnyObject {

    /// Setting delegate object to receive socket events
    /// - Parameter delegate: Delegate object subscribes for socket events
    func set(delegate: WebSocketDelegate)

    ///  Establishing web-socket connection
    /// - Parameter request: Web-socket request that describes all needed details
    func connect(using request: WebSocketRequest)

    /// Disconnecting the socket
    func disconnect()

    /// Send binary data to the server
    /// - Parameter data: Binary data
    func send(data: Data)

    /// Send plain text message
    /// - Parameter string: text message
    func send(string: String)

    ///  Send ping to the server
    func ping()
}
