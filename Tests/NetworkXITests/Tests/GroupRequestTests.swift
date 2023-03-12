//
//  GroupRequestTests.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import XCTest
@testable import NetworkXI

final class GroupRequestTests: NetworkXITests {

    private func fetch(_ value: String) async throws -> String {
        let request = AnythingRequest(parameters: ["value": value])
        let response = await networkService.make(request)

        guard response.success else {
            throw response.error ?? .unknown
        }

        guard let body = response.jsonBody,
              let json = body["json"] as? [String: String],
              let value = json["value"] else {
            throw NetworkError.unknown
        }

        return value
    }

    private func fetch(initialValues: [String]) async throws -> [String] {
        return try await withThrowingTaskGroup(of: String.self) { group in
            var values = [String]()

            for initialValue in initialValues {
                group.addTask { try await self.fetch(initialValue) }
            }

            for try await value in group {
                values.append(value)
            }

            return values
        }
    }

    private func fetchInSequence(initialValues: [String]) async throws -> [String] {
        var values = [String]()

        for initialValue in initialValues {
            async let value = fetch(initialValue)
            values.append(try await value)
        }

        return values
    }

    func testGroupRequests() {
        let expectation = expectation(description: #function)

        Task {
            defer { expectation.fulfill() }

            do {
                let initialValues = Array(1...3).map { $0.description }
                let values = try await fetch(initialValues: initialValues)
                XCTAssert(values.sorted() == initialValues)
            } catch {
                XCTAssert(false)
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testGroupRequestsInSequence() {
        let expectation = expectation(description: #function)

        Task {
            defer { expectation.fulfill() }

            do {
                let initialValues = Array(1...3).map { $0.description }
                let values = try await fetchInSequence(initialValues: initialValues)
                XCTAssert(values == initialValues)
            } catch {
                XCTAssert(false)
            }
        }

        wait(for: [expectation], timeout: 5)
    }
}
