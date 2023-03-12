//
//  SessionTaskKeeper.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

class SessionTaskKeeper {

    var response: URLResponse?

    var data: Data?

    var error: Error?
    
    private let completionHandler: (Data?, URLResponse?, Error?) -> Void

    init(_ completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.completionHandler = completionHandler
    }

    func handleCompletion() { completionHandler(data, response, error) }
}
