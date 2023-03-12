//
//  WebSocketDelegate.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public protocol WebSocketDelegate: AnyObject {

    func connected()

    func disconnected()

    func didSend(string: String, result: Result<Void, Error>)

    func didSend(data: Data, result: Result<Void, Error>)

    func received(data: Data)

    func received(string: String)

    func received(error: Error)

    func receivedPong()
}

public extension WebSocketDelegate {

    func connected() {}

    func disconnected() {}

    func didSend(string: String, result: Result<Void, Error>) {}

    func didSend(data: Data, result: Result<Void, Error>) {}

    func received(data: Data) {}

    func received(string: String) {}

    func received(error: Error) {}

    func receivedPong() {}
}
