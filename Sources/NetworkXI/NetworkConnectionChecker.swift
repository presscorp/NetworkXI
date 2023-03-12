//
//  NetworkConnectionChecker.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Network

protocol NetworkConnectionChecker: AnyObject {

    var connectionMonitor: NWPathMonitor { get }

    var connectionMonitorQueue: DispatchQueue { get }

    var networkIsReachable: Bool { get set }
}

extension NetworkConnectionChecker {

    func runConnectionMonitor() {
        connectionMonitor.pathUpdateHandler = { [weak self] newPath in
            guard let connectionMonitor = self else { return }
            connectionMonitor.networkIsReachable = newPath.status == .satisfied
        }
        connectionMonitor.start(queue: connectionMonitorQueue)
    }

    func stopConnectionMonitor() {
        connectionMonitor.cancel()
    }
}
