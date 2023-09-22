//
//  NetworkLogger.swift
//  
//
//  Created by Zhalgas Baibatyr on 18.09.2023.
//

import Foundation

public protocol NetworkLogger: AnyObject {

    func log(request: URLRequest)

    func log(
        request: URLRequest,
        response: HTTPURLResponse?,
        responseData: Data?,
        error: Error?,
        responseIsCached: Bool,
        responseIsMocked: Bool
    )
}
