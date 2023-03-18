//
//  DemoPiesocketComURL.swift
//  
//
//  Created by Zhalgas on 07.03.2023.
//

import NetworkXI

struct DemoPiesocketComURL: WebSocketURLExtensible {

    let path: String
    var host: String { "demo.piesocket.com" }
}

extension DemoPiesocketComURL {

    static let v3Networkxi = Self("/v3/networkxi")
}
