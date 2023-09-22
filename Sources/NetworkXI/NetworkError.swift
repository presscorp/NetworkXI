//
//  NetworkError.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public struct NetworkError: RawRepresentable, Equatable, Error {

    public let rawValue: String

    public let serverError: Error?

    public init(rawValue: String = #function) {
        self.rawValue = rawValue
        serverError = nil
    }

    public init(rawValue: String = #function, serverError: Error?) {
        self.rawValue = [rawValue, serverError?.localizedDescription].compactMap { $0 }.joined(separator: " | ")
        self.serverError = serverError
    }
}

public extension NetworkError {

    /// Error implies that something went wrong
    static var unknown: Self { Self() }

    /// Error implies that request was cancelled for some reasons
    static var cancelled: Self { Self() }

    /// Error implies that network connection is not available
    static var notAvailable: Self { Self() }

    /// Error implies that request was timed out
    static var timeout: Self { Self() }

    /// Composing custom server related error based on optional error
    /// - Parameter error: Fundamntal network error
    /// - Returns: Custom server-side error
    static func server(_ error: NSError?) -> Self { Self(serverError: error) }
}
