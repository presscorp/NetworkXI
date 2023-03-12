//
//  WebSocketSessionInterface.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public protocol WebSocketSessionInterface: AnyObject {

    var delegate: WebSocketSessionAdapterDelegate? { get set }

    var additionalHTTPHeaders: [String: String] { get set }

    var defaultSSLChallengeEnabled: Bool { get set }

    var sslCertificates: [NSData] { get set }

    var loggingEnabled: Bool { get set }

    init()

    func resumedTask(with request: URLRequest) -> WebSocketTask

    func send(string: String, via task: WebSocketTask)

    func send(data: Data, via task: WebSocketTask)

    func ping(via task: WebSocketTask)
}
