//
//  NetworkError.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

public struct NetworkError: RawRepresentable, Equatable, Error {

    public let rawValue: String

    public let error: NSError?

    public init(rawValue: String = #function) {
        self.rawValue = rawValue
        error = nil
    }

    public init(rawValue: String = #function, _ error: NSError) {
        self.rawValue = rawValue + " | " + error.localizedDescription
        self.error = error
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
    static func serverSide(_ error: NSError? = nil) -> Self {
        guard let error = error else { return Self() }
        return Self(error)
    }
}
