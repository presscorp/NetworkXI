//
//  SessionRenewalTest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import XCTest
@testable import NetworkXI

final class SessionRenewalTest: NetworkXITests {

    let request = StatusRequest()

    override func setUp() async throws {
        try await super.setUp()
        request.code = "401"
        sessionInterface.sessionRenewal = self
    }

    func testSessionRenewal() {
        let expectation = expectation(description: #function)

        Task {
            let response = await networkService.make(request)
            XCTAssert(response.success)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}

extension SessionRenewalTest: SessionRenewalService {

    func renew() async throws {
        request.code = "200"
    }
}
