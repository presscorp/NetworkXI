//
//  ClassicNetworkSessionAdapter.swift
//
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation
import Network

/// Classic implementation of adapter between fundamental network session and its worker (request maker);
/// It's much better to use worker (NetworkService) instead of applying adapter directly for network tasks
public class ClassicNetworkSessionAdapter: SessionAuthChallenger, SessionLifeCycle, NetworkConnectionChecker {

    public var defaultSSLChallengeEnabled = false

    public var sslCertificates = [NSData]()

    public var additionalHTTPHeaders = [String: String]()

    public weak var sessionRenewal: SessionRenewalService?

    public var loggingEnabled = false

    private lazy var session = setNewSession()

    private let sessionDelegate = SessionDelegationHandler()

    var taskKeepers = [Int: SessionTaskKeeper]()

    var networkIsReachable = false

    let connectionMonitor = NWPathMonitor()

    let connectionMonitorQueue = DispatchQueue(label: String(describing: NetworkConnectionChecker.self))

    public required init() {
        sessionDelegate.authChallenge = self
        sessionDelegate.lifeCycle = self
        runConnectionMonitor()
    }

    deinit {
        stopConnectionMonitor()
    }

    private func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTask {
        let dataTask = session.dataTask(with: request)
        let taskKeeper = SessionTaskKeeper(completionHandler)
        sessionDelegate.lifeCycle?.taskKeepers[dataTask.taskIdentifier] = taskKeeper
        return dataTask
    }

    private func uploadTask(
        with request: URLRequest,
        from bodyData: Data,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionTask {
        let dataTask = session.uploadTask(with: request, from: bodyData)
        let taskKeeper = SessionTaskKeeper(completionHandler)
        sessionDelegate.lifeCycle?.taskKeepers[dataTask.taskIdentifier] = taskKeeper
        return dataTask
    }
}

extension ClassicNetworkSessionAdapter: NetworkSessionInterface {

    @discardableResult
    public func setNewSession(
        configuration: URLSessionConfiguration = URLSession.shared.configuration,
        delegateQueue: OperationQueue? = nil
    ) -> URLSession {
        let configuration = URLSession.shared.configuration
        session = URLSession(
            configuration: configuration,
            delegate: sessionDelegate,
            delegateQueue: delegateQueue
        )
        return session
    }

    public func make(_ request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let adapter = self else { return }
            adapter.dataTask(with: request) { data, response, error in
                guard let response = response else {
                    if let error = error {
                        return continuation.resume(throwing: error)
                    } else {
                        return continuation.resume(throwing: NSError(domain: "", code: NSURLErrorUnknown))
                    }
                }

                continuation.resume(returning: (data ?? Data(), response))
            } .resume()
        }
    }

    public func make(_ request: URLRequest, with bodyData: Data) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            guard let adapter = self else { return }
            adapter.uploadTask(with: request, from: bodyData) { data, response, error in
                guard let response = response else {
                    if let error = error {
                        return continuation.resume(throwing: error)
                    } else {
                        return continuation.resume(throwing: NSError(domain: "", code: NSURLErrorUnknown))
                    }
                }

                continuation.resume(returning: (data ?? Data(), response))
            } .resume()
        }
    }

    public func networkIsAvailable() -> Bool { networkIsReachable }
}
