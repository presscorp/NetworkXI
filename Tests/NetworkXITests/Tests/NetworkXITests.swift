//
//  NetworkXITests.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import XCTest
@testable import NetworkXI

class NetworkXITests: XCTestCase {

    let sessionInterface: NetworkSessionInterface = {
        let sessionAdapter = NetworkSessionAdapter()
        sessionAdapter.defaultSSLChallengeEnabled = true
        sessionAdapter.loggingEnabled = true
        return sessionAdapter
    }()

    lazy var networkService: NetworkService = NetworkWorker(sessionInterface: sessionInterface)
}
