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

    private weak var delegate: WebSocketDelegate?

    ///  Initializer that accepts session adapter argument
    /// - Parameter sessionAdapter: Configured session adapter
    public init(sessionInterface: WebSocketSessionInterface) {
        self.sessionInterface = sessionInterface
        sessionInterface.delegate = self
    }

    deinit { disconnect() }

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

extension WebSocketWorker: WebSocketSessionAdapterDelegate {

    public func connected() {
        if sessionInterface.loggingEnabled { task?.originalRequest.map(WebSocketLogger.logConnection) }

        delegate?.connected()
    }

    public func disconnected(withCloseCode code: URLSessionWebSocketTask.CloseCode) {
        delegate?.disconnected()
    }

    public func didSend(string: String, result: Result<Void, Error>) {
        if sessionInterface.loggingEnabled {
            switch result {
            case .success: WebSocketLogger.log(sentMessage: string)
            case .failure(let error): WebSocketLogger.log(sentMessage: string, error: error)
            }
        }

        delegate?.didSend(string: string, result: result)
    }

    public func didSend(data: Data, result: Result<Void, Error>) {
        if sessionInterface.loggingEnabled {
            switch result {
            case .success: WebSocketLogger.log(sentData: data)
            case .failure(let error): WebSocketLogger.log(sentData: data, error: error)
            }
        }

        delegate?.didSend(data: data, result: result)
    }

    public func received(data: Data) {
        if sessionInterface.loggingEnabled { WebSocketLogger.log(receivedData: data) }

        delegate?.received(data: data)
    }

    public func received(string: String) {
        if sessionInterface.loggingEnabled { WebSocketLogger.log(receivedMessage: string) }

        delegate?.received(string: string)
    }

    public func received(error: Error) {
        if sessionInterface.loggingEnabled { WebSocketLogger.log(error: error) }

        delegate?.received(error: error)
    }

    public func receivedPong() {
        if sessionInterface.loggingEnabled { WebSocketLogger.logPingPong() }

        delegate?.receivedPong()
    }
}

extension WebSocketWorker: WebSocketService {

    public func set(delegate: WebSocketDelegate) {
        self.delegate = delegate
    }

    public func connect(using request: WebSocketRequest) {
        guard let urlRequest = composeUrlRequest(from: request) else { return }
        if sessionInterface.loggingEnabled { WebSocketLogger.log(request: urlRequest) }
        task = sessionInterface.resumedTask(with: urlRequest)
    }

    public func disconnect() {
        task?.cancel(with: .goingAway, reason: "goingAway".data(using: .utf8))
    }

    public func send(data: Data) {
        guard let task = task else {
            delegate?.didSend(data: data, result: .failure(NetworkError.cancelled))
            return
        }
        sessionInterface.send(data: data, via: task)
    }

    public func send(string: String) {
        guard let task = task else {
            delegate?.didSend(string: string, result: .failure(NetworkError.cancelled))
            return
        }
        sessionInterface.send(string: string, via: task)
    }

    public func ping() {
        guard let task = task else {
            delegate?.received(error: NetworkError.cancelled)
            return
        }
        sessionInterface.ping(via: task)
    }
}
