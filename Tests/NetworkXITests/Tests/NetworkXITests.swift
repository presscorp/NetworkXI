//
//  NetworkXITests.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import XCTest
@testable import NetworkXI

class NetworkXITests: XCTestCase {

    var sessionInterface: NetworkSessionInterface!
    var networkService: NetworkService!

    override func setUp() async throws {
        try await super.setUp()

        let sessionAdapter = NetworkSessionAdapter()
        sessionAdapter.defaultSSLChallengeEnabled = true
        sessionAdapter.loggingEnabled = true
        sessionInterface = sessionAdapter

        networkService = NetworkWorker(sessionInterface: sessionInterface)
    }

    override func tearDown() async throws {
        networkService = nil
        sessionInterface = nil
        try await super.tearDown()
    }
}
