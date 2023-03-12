//
//  WebSocketLifeCycleService.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

protocol WebSocketLifeCycleService: AnyObject {

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    )

    func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    )

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)

    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
}
