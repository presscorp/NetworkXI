//
//  WebSocketRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

public protocol WebSocketRequest: AnyObject {

    var url: WebSocketURL { get }

    var parameters: [String: Any] { get }

    func edit(httpHeaders: inout [String: String])
}

public extension WebSocketRequest {

    var parameters: [String: Any] { [:] }

    func edit(httpHeaders: inout [String: String]) {}
}
