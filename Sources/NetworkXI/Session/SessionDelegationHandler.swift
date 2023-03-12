//
//  SessionDelegationHandler.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

class SessionDelegationHandler: NSObject {

    weak var authChallenge: SessionAuthChallengeService?

    weak var lifeCycle: SessionLifeCycleService?

    weak var webSocketLifeCycle: WebSocketLifeCycleService?
}

extension SessionDelegationHandler: URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard let authChallenge = authChallenge else {
            return (.cancelAuthenticationChallenge, nil)
        }
        return await authChallenge.urlSession(session, didReceive: challenge)
    }
}

extension SessionDelegationHandler: URLSessionTaskDelegate {

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let lifeCycle = lifeCycle {
            lifeCycle.urlSession(session, task: task, didCompleteWithError: error)
        } else if let webSocketLifeCycle = webSocketLifeCycle {
            webSocketLifeCycle.urlSession(session, task: task, didCompleteWithError: error)
        }
    }
}

extension SessionDelegationHandler: URLSessionDataDelegate {

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        guard let lifeCycle = lifeCycle else { return .allow }
        return await lifeCycle.urlSession(session, dataTask: dataTask, didReceive: response)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let lifeCycle = lifeCycle else { return }
        lifeCycle.urlSession(session, dataTask: dataTask, didReceive: data)
    }
}

extension SessionDelegationHandler: URLSessionWebSocketDelegate {

    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {
        webSocketLifeCycle?.urlSession(session, webSocketTask: webSocketTask, didOpenWithProtocol: `protocol`)
    }

    public func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        webSocketLifeCycle?.urlSession(session, webSocketTask: webSocketTask, didCloseWith: closeCode, reason: reason)
    }

    public func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        webSocketLifeCycle?.urlSession(session, didBecomeInvalidWithError: error)
    }
}
