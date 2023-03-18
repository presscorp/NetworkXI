//
//  WebSocketWorker.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

/// Worker class intended for web-socket tasks
public class WebSocketWorker {

    private let sessionInterface: WebSocketSessionInterface

    private weak var task: WebSocketTask?

    private var streamContinuation: WebSocketStream.Continuation?

    private var stream: WebSocketStream?

    private var newStream: WebSocketStream {
        return WebSocketStream { [weak self] continuation in
            self?.streamContinuation = continuation

            Task { [weak task] in
                guard let task else { return }
                do {
                    while task.closeCode == .invalid {
                        let message = try await task.receive()
                        if sessionInterface.loggingEnabled {
                            if case .string(let string) = message {
                                WebSocketLogger.log(receivedMessage: string)
                            } else if case .data(let data) = message {
                                WebSocketLogger.log(receivedData: data)
                            }
                        }

                        continuation.yield(message)
                    }
                } catch {
                    if sessionInterface.loggingEnabled { WebSocketLogger.log(error: error) }
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    ///  Initializer that accepts session adapter argument
    /// - Parameter sessionAdapter: Configured session adapter
    public init(sessionInterface: WebSocketSessionInterface) {
        self.sessionInterface = sessionInterface
    }

    deinit {
        Task { try await disconnect() }
    }

    private func composeUrlRequest(from request: WebSocketRequest) -> URLRequest? {
        var urlComponents = URLComponents(string: request.url.absolutePath)
        urlComponents?.percentEncodedQueryItems = request.parameters.compactMap { name, value -> URLQueryItem? in
            guard let value = (value as? CustomStringConvertible)?.description else { return nil }
            return URLQueryItem(name: name, value: value)
        }
        guard let url = urlComponents?.url else { return nil }

        var urlRequest = URLRequest(url: url)

        // Compose headers
        var allHTTPHeaderFields = [String: String]()
        sessionInterface.additionalHTTPHeaders.forEach { allHTTPHeaderFields[$0] = $1 }
        request.edit(httpHeaders: &allHTTPHeaderFields)
        urlRequest.allHTTPHeaderFields = allHTTPHeaderFields

        return urlRequest
    }
}

extension WebSocketWorker: WebSocketService {

    public typealias Element = URLSessionWebSocketTask.Message

    public func makeAsyncIterator() -> AsyncIterator {
        guard let stream else {
            stream = newStream
            return makeAsyncIterator()
        }

        return stream.makeAsyncIterator()
    }

    public func connect(using request: WebSocketRequest) async throws {
        guard let urlRequest = composeUrlRequest(from: request) else { throw NetworkError.unknown }
        if sessionInterface.loggingEnabled { WebSocketLogger.log(request: urlRequest) }
        do {
            task = try await sessionInterface.resumedTask(with: urlRequest)
            if sessionInterface.loggingEnabled { WebSocketLogger.logConnection(for: urlRequest) }
            stream = newStream
        } catch {
            WebSocketLogger.log(error: error)
            throw error
        }
    }

    public func disconnect() async throws {
        task?.cancel(with: .goingAway, reason: "goingAway".data(using: .utf8))
        streamContinuation?.finish()
        streamContinuation = nil
        stream = nil
        do {
            try await sessionInterface.awaitDisconnect()
            if sessionInterface.loggingEnabled { WebSocketLogger.logDisconnection() }
        } catch {
            WebSocketLogger.log(error: error)
            throw error
        }
    }

    public func send(data: Data) async throws {
        guard let task = task else { throw NetworkError.cancelled }
        do {
            try await sessionInterface.send(data: data, via: task)
            if sessionInterface.loggingEnabled { WebSocketLogger.log(sentData: data) }
        } catch {
            if sessionInterface.loggingEnabled { WebSocketLogger.log(sentData: data, error: error) }
            throw error
        }
    }

    public func send(string: String) async throws {
        guard let task = task else { throw NetworkError.cancelled }
        do {
            try await sessionInterface.send(string: string, via: task)
            if sessionInterface.loggingEnabled { WebSocketLogger.log(sentMessage: string) }
        } catch {
            if sessionInterface.loggingEnabled { WebSocketLogger.log(sentMessage: string, error: error) }
            throw error
        }
    }

    public func ping() async throws {
        guard let task = task else { throw NetworkError.cancelled }
        do {
            if sessionInterface.loggingEnabled { WebSocketLogger.logPing() }
            try await sessionInterface.ping(via: task)
            if sessionInterface.loggingEnabled { WebSocketLogger.logPong() }
        } catch {
            WebSocketLogger.log(error: error)
            throw error
        }
    }
}
