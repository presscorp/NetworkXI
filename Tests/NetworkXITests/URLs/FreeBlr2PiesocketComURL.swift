//
//  FreeBlr2PiesocketComURL.swift
//  
//
//  Created by Zhalgas on 07.03.2023.
//

import NetworkXI

struct FreeBlr2PiesocketComURL: WebSocketURLExtensible {

    let path: String
    var host: String { "free.blr2.piesocket.com" }
}

extension FreeBlr2PiesocketComURL {

    static let v31 = Self("/v3/1")
}
