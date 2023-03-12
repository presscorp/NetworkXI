//
//  RequestTests.swift
//
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import XCTest
@testable import NetworkXI

final class RequestTests: NetworkXITests {

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

    func testMultipartRequest() {
        let expectation = expectation(description: #function)

        let bundle = Bundle.module
        let image = UIImage(named: "image32x32", in: bundle, with: nil)
        guard let uploadImageData = image?.pngData() else {
            return XCTAssert(false)
        }

        let params = (uploadImageData, "file", "image32x32.png", uploadImageData.mimeType)

        Task {
            defer { expectation.fulfill() }

            let request = UploadRequest(paramsArray: [params])
            let response = await networkService.make(request)

            guard response.success,
                  let body = response.jsonBody,
                  let files = body["files"] as? [String: String],
                  let file = files["file"] else {
                return XCTAssert(false)
            }

            func imageData(fromBase64 string: String) -> Data? {
                guard let url = URL(string: string) else { return nil }
                return try? Data(contentsOf: url)
            }

            let downloadImageData = imageData(fromBase64: file)
            XCTAssertEqual(uploadImageData, downloadImageData)
        }

        wait(for: [expectation], timeout: 5)
    }
}
