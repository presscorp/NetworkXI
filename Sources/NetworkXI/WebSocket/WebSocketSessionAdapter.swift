//
//  WebSocketSessionAdapter.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

/// Adapter between fundamental web-socket and its worker (socket service);
/// It's much better to use worker (WebSocketWorker) instead of applying adapter directly for socket message exchange
public class WebSocketSessionAdapter: SessionAuthChallenger {

    public var additionalHTTPHeaders = [String: String]()

    public var defaultSSLChallengeEnabled = false

    public var sslCertificates = [NSData]()

    public var loggingEnabled = false

    private weak var session: URLSession?

    private let sessionDelegate = SessionDelegationHandler()

    private var connectContinuation: CheckedContinuation<WebSocketTask, Error>?

    private var disconnectContinuation: CheckedContinuation<URLSessionWebSocketTask.CloseCode, Error>?

    public required init() {
        sessionDelegate.authChallenge = self
        sessionDelegate.webSocketLifeCycle = self
    }

    private func process(error: Error) {
        connectContinuation?.resume(throwing: error)
        disconnectContinuation?.resume(throwing: error)
    }
}

extension WebSocketSessionAdapter: WebSocketSessionInterface {

    public func resumedTask(with request: URLRequest) async throws -> WebSocketTask {
        let session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: .main)
        let task = session.webSocketTask(with: request)
        task.resume()
        session.finishTasksAndInvalidate()

        defer {
            self.session = session
            connectContinuation = nil
        }

        return try await withCheckedThrowingContinuation { [weak self] in self?.connectContinuation = $0 }
    }

    @discardableResult
    public func awaitDisconnect() async throws -> URLSessionWebSocketTask.CloseCode {
        defer { disconnectContinuation = nil }
        return try await withCheckedThrowingContinuation { [weak self] in self?.disconnectContinuation = $0 }
    }

    public func send(string: String, via task: WebSocketTask) async throws {
        try await task.send(.string(string))
    }

    public func send(data: Data, via task: WebSocketTask) async throws {
        try await task.send(.data(data))
    }

    public func ping(via task: WebSocketTask) async throws {
        return try await withCheckedThrowingContinuation { [weak task] continuation in
            task?.sendPing { error in
                if let error { return continuation.resume(throwing: error) }
                continuation.resume()
            }
        }
    }
}

extension WebSocketSessionAdapter: WebSocketLifeCycleService {

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        connectContinuation?.resume(returning: webSocketTask)
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        disconnectContinuation?.resume(returning: closeCode)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        error.map(process)
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        error.map(process)
    }
}
