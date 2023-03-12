//
//  SocketRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import NetworkXI

class SocketRequest: WebSocketRequest {

    var url: WebSocketURL { DemoPiesocketComURL.v3Channel_123 }
    let parameters: [String: Any]

    init(api_key: String) {
        parameters = ["api_key": api_key]
    }
}
