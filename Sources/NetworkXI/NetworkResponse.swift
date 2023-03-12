//
//  NetworkResponse.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public protocol NetworkResponse {

    var statusCode: Int { get }

    var success: Bool { get }

    var body: Data? { get }

    var error: NetworkError? { get }

    var headers: [AnyHashable: Any] { get }
}

public extension NetworkResponse {

    var success: Bool { 200..<300 ~= statusCode }

    var jsonBody: [String: Any]? { body?.dictionary }

    var plaintextBody: String? { body?.utf8EncodedString }

    func decode<T: Decodable>() throws -> T {
        guard let data = body else {
            let description = "Expected Optional<Data> value but found nil instead"
            let context = DecodingError.Context(codingPath: [], debugDescription: description)
            let error = DecodingError.valueNotFound(Optional<Data>.self, context)
            throw error
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
