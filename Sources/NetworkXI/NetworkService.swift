//
//  NetworkService.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

/// Base service to perform network request
public protocol NetworkService: AnyObject {

    /// Making HTTP request to recieve server response
    /// - Parameter request: Network request that describes all details
    /// - Returns: Generated network response
    func make<T: NetworkRequest>(_ request: T) async -> NetworkResponse
}
