//
//  MockRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import XCTest
@testable import NetworkXI

final class MockRequestTests: NetworkXITests {

    func testMock() {
        let expectation = expectation(description: #function)

        Task {
            defer { expectation.fulfill() }

            let request = MockRequest(parameters: ["key": "value"])
            let response = await networkService.make(request)

            guard response.success,
                  let dict = response.jsonBody as? [String: String] else {
                return XCTAssert(false)
            }

            XCTAssert(dict["key"] == "value")
        }

        wait(for: [expectation], timeout: 5)
    }
}
