//
//  FailureResponse.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public struct FailureResponse: NetworkResponse {

    public let statusCode: Int

    public let body: Data?

    public let error: NetworkError?

    public let headers: [AnyHashable: Any]

    public init(statusCode: Int, error: NetworkError, body: Data? = nil, headers: [AnyHashable: Any] = [:]) {
        self.statusCode = statusCode
        self.error = error
        self.body = body
        self.headers = headers
    }
}

public extension FailureResponse {

    static var cancelled: Self { Self(statusCode: NSURLErrorCancelled, error: .cancelled) }

    static var timeout: Self { Self(statusCode: NSURLErrorTimedOut, error: .timeout) }

    static var unknown: Self { Self(statusCode: NSURLErrorUnknown, error: .unknown) }

    static var notAvailable: Self { Self(statusCode: NSURLErrorNotConnectedToInternet, error: .notAvailable) }

    static func server(code: Int, error: NSError?) -> Self { Self(statusCode: code, error: .server(error)) }
}
