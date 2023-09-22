//
//  CachedResponseTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 21.09.2023.
//

import XCTest
@testable import NetworkXI

final class CachedResponseTests: NetworkXITests {

    var request: NetworkRequest!

    override func setUp() async throws {
        try await super.setUp()

        request = PngImageRequest()
    }

    override func tearDown() {
        request = nil

        super.tearDown()
    }

    func testCachedResponse() async {
        var responseHeaders1 = [String: String]()
        let response = await networkService.make(request)
        XCTAssert(response.success)
        for (key, value) in response.headers {
            guard let key = key as? String, let value = value as? String else {
                continue
            }
            responseHeaders1[key] = value
        }

        sleep(1)

        var responseHeaders2 = [String: String]()
        let response2 = await networkService.make(request)
        XCTAssert(response.success)
        for (key, value) in response2.headers {
            guard let key = key as? String, let value = value as? String else {
                continue
            }
            responseHeaders2[key] = value
        }

        XCTAssertEqual(responseHeaders1, responseHeaders2)
    }

    func testClearCachedResponseForRequest() async {
        var responseHeaders1 = [String: String]()
        let response1 = await networkService.make(request)
        XCTAssert(response1.success)
        for (key, value) in response1.headers {
            guard let key = key as? String, let value = value as? String else {
                continue
            }
            responseHeaders1[key] = value
        }

        sleep(1)

        var responseHeaders2 = [String: String]()
        let response2 = await networkService.make(request)
        XCTAssert(response2.success)
        for (key, value) in response2.headers {
            guard let key = key as? String, let value = value as? String else {
                continue
            }
            responseHeaders2[key] = value
        }

        XCTAssertEqual(responseHeaders1, responseHeaders2)

        networkService.clearCachedResponse(for: request)

        sleep(1)

        var responseHeaders3 = [String: String]()
        let response3 = await networkService.make(request)
        XCTAssert(response3.success)
        for (key, value) in response3.headers {
            guard let key = key as? String, let value = value as? String else {
                continue
            }
            responseHeaders3[key] = value
        }

        XCTAssertNotEqual(responseHeaders2, responseHeaders3)
    }
}
