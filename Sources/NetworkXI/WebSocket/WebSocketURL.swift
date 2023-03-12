//
//  WebSocketURL.swift
//  
//
//  Created by Zhalgas on 07.03.2023.
//

public protocol WebSocketURL: RequestURL {}

public extension WebSocketURL {

    var scheme: String { "wss://" }
}

public typealias WebSocketURLExtensible = RequestURLExtensible & WebSocketURL
