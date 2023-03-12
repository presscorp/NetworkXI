//
//  MockRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation
import NetworkXI

class MockRequest: NetworkRequest {

    var url: RequestURL { MockURL.mock }
    var method: RequestMethod { .POST }
    var encoding: RequestContentEncoding { .json }
    let parameters: [String: Any]

    var mockResponse: NetworkResponse? {
        let data = try? JSONSerialization.data(withJSONObject: parameters)
        return SuccessResponse(statusCode: 200, body: data, headers: [:])
    }

    init(parameters: [String: Any]) {
        self.parameters = parameters
    }
}
