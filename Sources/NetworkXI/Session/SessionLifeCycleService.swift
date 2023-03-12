//
//  SessionLifeCycleService.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

protocol SessionLifeCycleService: AnyObject {

    var taskKeepers: [Int: SessionTaskKeeper] { get set }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive response: URLResponse
    ) async -> URLSession.ResponseDisposition

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
}
