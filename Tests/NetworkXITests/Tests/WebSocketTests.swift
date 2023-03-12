//
//  WebSocketTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation
import XCTest
import NetworkXI

class WebSocketTests: XCTestCase {

    lazy var sessionInterface = { () -> WebSocketSessionInterface in
        let sessionAdapter = WebSocketSessionAdapter()
        sessionAdapter.loggingEnabled = true
        sessionAdapter.defaultSSLChallengeEnabled = true
        return sessionAdapter
    }()

    lazy var webSocketService: WebSocketService = WebSocketWorker(sessionInterface: sessionInterface)
    let dispatchGroup = DispatchGroup()

    private let string1ToSend = "Test message 1"
    private let string2ToSend = "Test message 2"
    private var openConnectionTestClosure: (() -> Void)?
    private var pingPongClosure: (() -> Void)?
    private var sendString1TestClosure: (() -> Void)?
    private var sendString2TestClosure: (() -> Void)?
    private var receiveString1TestClosure: (() -> Void)?
    private var receiveString2TestClosure: (() -> Void)?
    private var closeConnectionTestClosure: (() -> Void)?

    func testWebSocket() {

        webSocketService.set(delegate: self)
        let request = SocketRequest(api_key: "VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self")
        webSocketService.connect(using: request)

        let dispatchGroup = DispatchGroup()

        dispatchGroup.enter()
        let expectation0 = expectation(description: "Open connection test")
        openConnectionTestClosure = {
            expectation0.fulfill()
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        let expectation1 = expectation(description: "Ping-pong test")
        pingPongClosure = {
            expectation1.fulfill()
            dispatchGroup.leave()
        }
        webSocketService.ping()

        dispatchGroup.enter()
        let expectation2 = expectation(description: "Send string 1 test")
        sendString1TestClosure = {
            expectation2.fulfill()
            dispatchGroup.leave()
        }
        webSocketService.send(string: string1ToSend)

        dispatchGroup.enter()
        let expectation3 = expectation(description: "Send string 2 test")
        sendString2TestClosure = {
            expectation3.fulfill()
            dispatchGroup.leave()
        }
        webSocketService.send(string: string2ToSend)

        dispatchGroup.enter()
        let expectation4 = expectation(description: "Receive string 1 test")
        receiveString1TestClosure = {
            expectation4.fulfill()
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        let expectation5 = expectation(description: "Receive string 2 test")
        receiveString2TestClosure = {
            expectation5.fulfill()
            dispatchGroup.leave()
        }

        let expectation6 = expectation(description: "Close connection test")
        closeConnectionTestClosure = {
            expectation6.fulfill()
        }

        dispatchGroup.notify(queue: .main) { [weak webSocketService] in
            webSocketService?.disconnect()
        }

        let expectations = [
            expectation0, expectation1, expectation2, expectation3, expectation4, expectation5, expectation6
        ]
        wait(for: expectations, timeout: 3)
    }
}

extension WebSocketTests: WebSocketDelegate {

    func connected() {
        openConnectionTestClosure?()
    }

    func disconnected() {
        closeConnectionTestClosure?()
    }

    func didSend(string: String, result: Result<Void, Error>) {
        guard case .success = result else { return }
        if string == string1ToSend {
            sendString1TestClosure?()
        } else if string == string2ToSend {
            sendString2TestClosure?()
        }
    }

    func received(string: String) {
        if string == string1ToSend {
            receiveString1TestClosure?()
        } else if string == string2ToSend {
            receiveString2TestClosure?()
        }
    }

    func receivedPong() {
        pingPongClosure?()
    }
}
