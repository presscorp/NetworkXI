//
//  SessionLifeCycle.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

protocol SessionLifeCycle: SessionLifeCycleService {}

extension SessionLifeCycle {

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition {
        let taskKeeper = taskKeepers[dataTask.taskIdentifier]
        guard let taskKeeper = taskKeeper else { return .cancel }
        taskKeeper.response = response
        return .allow
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let completionMaker = taskKeepers[dataTask.taskIdentifier] else { return }
        if completionMaker.data == nil {
            completionMaker.data = Data()
        }
        completionMaker.data?.append(data)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let taskKeeper = taskKeepers[task.taskIdentifier] else { return }
        taskKeeper.error = error
        taskKeepers.removeValue(forKey: task.taskIdentifier)
        taskKeeper.handleCompletion()
    }
}
