//
//  AuthChallengeRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import XCTest
@testable import NetworkXI

final class AuthChallengeRequestTests: NetworkXITests {

    override func setUp() async throws {
        try await super.setUp()

        sessionInterface.defaultSSLChallengeEnabled = false
        if let file = Bundle.module.path(forResource: "httpbin.org", ofType: "cer"),
           let certData = NSData(contentsOfFile: file) {
            sessionInterface.sslCertificates = [certData]
        }
    }

    func testRequest() {
        let expectation = expectation(description: #function)

        Task {
            defer { expectation.fulfill() }

            let request = AnythingRequest(parameters: ["key": "value"])
            let response = await networkService.make(request)

            guard response.success,
                  let body = response.jsonBody,
                  let dict = body["json"] as? [String: String] else {
                return XCTAssert(false)
            }

            XCTAssert(dict["key"] == "value")
        }

        wait(for: [expectation], timeout: 5)
    }
}
