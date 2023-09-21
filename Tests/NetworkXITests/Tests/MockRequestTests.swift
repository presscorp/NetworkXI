//
//  MockRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import XCTest
@testable import NetworkXI

final class MockRequestTests: NetworkXITests {

    func testMock() async {
        let request = MockRequest(parameters: ["key": "value"])
        let response = await networkService.make(request)

        guard response.success,
              let dict = response.jsonBody as? [String: String] else {
            return XCTAssert(false)
        }

        XCTAssertEqual(dict["key"], "value")
    }
}
