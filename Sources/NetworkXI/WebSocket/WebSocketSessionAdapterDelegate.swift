//
//  WebSocketSessionAdapterDelegate.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public protocol WebSocketSessionAdapterDelegate: AnyObject {

    func connected()

    func disconnected(withCloseCode code: URLSessionWebSocketTask.CloseCode)

    func didSend(string: String, result: Result<Void, Error>)

    func didSend(data: Data, result: Result<Void, Error>)

    func received(data: Data)

    func received(string: String)

    func received(error: Error)

    func receivedPong()
}
