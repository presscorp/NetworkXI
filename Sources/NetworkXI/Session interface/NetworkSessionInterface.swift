//
//  NetworkSessionInterface.swift
//
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

/// Interface between fundamental network session and its worker (request maker)
public protocol NetworkSessionInterface: AnyObject {

    /// Common HTTP headers applied to all requests made within this session
    var additionalHTTPHeaders: [String: String] { get set }

    /// Default SSL certificate handling for the challenge
    var defaultSSLChallengeEnabled: Bool { get set }

    /// SSL certificates stored as binary data
    var sslCertificates: [NSData] { get set }

    /// Service intended for session renewal in case of specified condition (check for authorized request);
    /// Normally used to sign requests with updated authorization token
    var sessionRenewal: SessionRenewalService? { get set }

    /// Indication of log printing of request / response into the console
    var loggingEnabled: Bool { get set }

    /// Cache set to session's configuration
    var cache: URLCache? { get }

    init()

    /// Make fundamental HTTP request; It's much better to use worker (NetworkService) instead of applying this interface directly for network tasks
    /// - Parameter request: fundamental HTTP request
    /// - Returns: Data and fundamental HTTP response
    func make(_ request: URLRequest) async throws -> (Data, URLResponse)

    /// Upload data via fundamental HTTP request; It's much better to use worker (NetworkService) instead of applying this interface directly for network tasks
    /// - Parameters:
    ///   - request: fundamental HTTP request
    ///   - bodyData: Uploaded binary data
    /// - Returns: Data and fundamental HTTP response
    func make(_ request: URLRequest, with bodyData: Data) async throws -> (Data, URLResponse)

    /// Set new instance of URLSession
    /// - Parameters:
    ///   - configuration: A configuration object that specifies certain behaviors, such as caching policies, timeouts, proxies, pipelining, TLS versions to
    ///   support, cookie policies, and credential storage.
    ///   - delegateQueue: An operation queue for scheduling the delegate calls and completion handlers. The queue should be a serial queue, in order to ensure
    ///    the correct ordering of callbacks. If nil, the session creates a serial operation queue for performing all delegate method calls and completion handler
    ///    calls.
    /// - Returns: An object that coordinates a group of related, network data transfer tasks.
    @discardableResult
    func setNewSession(configuration: URLSessionConfiguration, delegateQueue: OperationQueue?) -> URLSession

    /// Network availability indicator
    /// - Returns: Boolean value that indicates whether network connection is available or not
    func networkIsAvailable() -> Bool
}
