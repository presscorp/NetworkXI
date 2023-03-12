//
//  SuccessResponse.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public struct SuccessResponse: NetworkResponse {

    public let statusCode: Int

    public let body: Data?

    public var error: NetworkError? { nil }

    public let headers: [AnyHashable: Any]

    public init(statusCode: Int, body: Data?, headers: [AnyHashable: Any]) {
        self.statusCode = statusCode
        self.body = body
        self.headers = headers
    }
}
