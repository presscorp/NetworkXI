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

    /// Common HTTP headers applied to connection made within this session
    public var additionalHTTPHeaders = [String: String]()

    public var defaultSSLChallengeEnabled = false

    public var sslCertificates = [NSData]()

    /// Indication of log printing for socket messages into the console
    public var loggingEnabled = false

    public weak var delegate: WebSocketSessionAdapterDelegate?

    private weak var session: URLSession?

    private let sessionDelegate = SessionDelegationHandler()

    private lazy var receiverCompletionHolder = ReceiverCompletionHolder { [weak self] result in
        guard let adapter = self, let delegate = adapter.delegate else { return }

        switch result {
        case .success(let message):
            switch message {
            case .data(let data): delegate.received(data: data)
            case .string(let string): delegate.received(string: string)
            @unknown default: break
            }
        case .failure(let error):
            adapter.process(error: error)
        }
    }

    public required init() {
        sessionDelegate.authChallenge = self
        sessionDelegate.webSocketLifeCycle = self
    }

    private func process(error: Error) {
        if let error = error as NSError?, error.code == NSURLErrorCancelled { return }
        delegate?.received(error: error)
    }
}

extension WebSocketSessionAdapter: WebSocketSessionInterface {

    public func resumedTask(with request: URLRequest) -> WebSocketTask {
        let session = URLSession(configuration: .ephemeral, delegate: sessionDelegate, delegateQueue: .main)
        self.session = session
        let task = session.webSocketTask(with: request)
        receiverCompletionHolder.setReceiver(for: task)
        task.resume()
        session.finishTasksAndInvalidate()
        return task
    }

    public func send(string: String, via task: WebSocketTask) {
        task.send(.string(string)) { [weak self] error in
            guard let adapter = self, let delegate = adapter.delegate else { return }
            if let error = error { return adapter.process(error: error) }
            delegate.didSend(string: string, result: .success(()))
        }
    }

    public func send(data: Data, via task: WebSocketTask) {
        task.send(.data(data)) { [weak self] error in
            guard let adapter = self, let delegate = adapter.delegate else { return }
            if let error = error { return adapter.process(error: error) }
            delegate.didSend(data: data, result: .success(()))
        }
    }

    public func ping(via task: WebSocketTask) {
        task.sendPing { [weak self] error in
            guard let adapter = self, let delegate = adapter.delegate else { return }
            if let error = error { return adapter.process(error: error) }
            delegate.receivedPong()
        }
    }
}

private extension WebSocketSessionAdapter {

    class ReceiverCompletionHolder {

        private let handle: (_ result: Result<URLSessionWebSocketTask.Message, Error>) -> Void

        init(handler: @escaping (_ result: Result<URLSessionWebSocketTask.Message, Error>) -> Void) {
            self.handle = handler
        }

        func setReceiver(for task: WebSocketTask) {
            task.receive { [weak self, weak task] result in
                guard let completionHolder = self, let task = task else { return }
                completionHolder.handle(result)
                if case .failure = result { return }
                completionHolder.setReceiver(for: task)
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
        delegate?.connected()
    }

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        if loggingEnabled { WebSocketLogger.logDisconnection() }
        delegate?.disconnected(withCloseCode: closeCode)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        error.map(process)
    }

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        error.map(process)
    }
}
