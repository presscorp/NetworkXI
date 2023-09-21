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

    var sessionInterface: WebSocketSessionInterface!

    var webSocketService: (any WebSocketService)!

    override func setUp() async throws {
        try await super.setUp()
        let sessionAdapter = WebSocketSessionAdapter()
        sessionAdapter.loggingEnabled = true
        sessionAdapter.defaultSSLChallengeEnabled = true
        sessionInterface = sessionAdapter

        webSocketService = WebSocketWorker(sessionInterface: sessionInterface)

        let request = SocketRequest(api_key: "VCXCEuvhGcBDP7XhiJJUDvR1e1D3eiVjgZ9VRiaV&notify_self")
        try await webSocketService.connect(using: request)
    }

    override func tearDown() async throws {
        try await webSocketService.disconnect()
        try await super.tearDown()
    }

    func testPingPong() async throws {
        try await webSocketService.ping()
    }

    func testSendReceiveMessage() async {
        let stringMessage = UUID().uuidString

        let expectation1 = expectation(description: "Send message")
        Task {
            do {
                try await webSocketService.send(string: stringMessage)
                expectation1.fulfill()
            } catch {
                return XCTAssert(false)
            }
        }

        let expectation2 = expectation(description: "Receive message")
        Task {
            do {
                for try await message in webSocketService {
                    guard case .string(let string) = message else { continue }
                    if string == stringMessage {
                        expectation2.fulfill()
                    }
                }
            } catch {
                return XCTAssert(false)
            }
        }

        let expectations = [expectation1, expectation2]
        await fulfillment(of: expectations, timeout: 5, enforceOrder: true)
    }
}
