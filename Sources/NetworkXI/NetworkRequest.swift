//
//  NetworkRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public protocol NetworkRequest: AnyObject {

    var url: RequestURL { get }

    var method: RequestMethod { get }

    var encoding: RequestContentEncoding { get }

    var encodesParametersInURL: Bool { get }

    var parameters: [String: Any] { get }

    var httpBody: Data? { get }

    var timeoutInterval: TimeInterval? { get set }

    var mockResponse: NetworkResponse? { get }

    func edit(httpHeaders: inout [String: String])
}

public extension NetworkRequest {

    var parameters: [String: Any] { [:] }

    var encodesParametersInURL: Bool { method == .GET }

    var httpBody: Data? { nil }

    var timeoutInterval: TimeInterval? {
        get { nil }
        set { _ = newValue }
    }

    var mockResponse: NetworkResponse? { nil }

    func edit(httpHeaders: inout [String: String]) {}

    static func encode<T: Codable>(_ object: T) throws -> Any {
        let data = try JSONEncoder().encode(object)
        return try JSONSerialization.jsonObject(with: data)
    }
}
