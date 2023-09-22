//
//  NetworkSessionAdapter.swift
//
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation
import Network

/// Adapter between fundamental network session and its worker (request maker);
/// It's much better to use worker (NetworkService) instead of applying adapter directly for network tasks
public class NetworkSessionAdapter: SessionAuthChallenger, NetworkConnectionChecker {

    public var defaultSSLChallengeEnabled = false

    public var sslCertificates = [NSData]()

    public var additionalHTTPHeaders = [String: String]()

    public weak var sessionRenewal: SessionRenewalService?

    public var loggingEnabled = false

    public private(set) weak var cache: URLCache?

    private lazy var session = setNewSession()

    private let sessionDelegate = SessionDelegationHandler()

    var networkIsReachable = false

    let connectionMonitor = NWPathMonitor()

    let connectionMonitorQueue = DispatchQueue(label: String(describing: NetworkConnectionChecker.self))

    public required init() {
        sessionDelegate.authChallenge = self
        runConnectionMonitor()
    }

    deinit {
        stopConnectionMonitor()
    }
}

extension NetworkSessionAdapter: NetworkSessionInterface {

    @discardableResult
    public func setNewSession(
        configuration: URLSessionConfiguration = URLSession.shared.configuration,
        delegateQueue: OperationQueue? = nil
    ) -> URLSession {
        session = URLSession(
            configuration: configuration,
            delegate: sessionDelegate,
            delegateQueue: delegateQueue
        )
        self.cache = configuration.urlCache
        return session
    }

    public func make(_ request: URLRequest) async throws -> (Data, URLResponse) {
        return try await session.data(for: request)
    }

    public func make(_ request: URLRequest, with bodyData: Data) async throws -> (Data, URLResponse) {
        return try await session.upload(for: request, from: bodyData)
    }

    public func networkIsAvailable() -> Bool { networkIsReachable }
}
