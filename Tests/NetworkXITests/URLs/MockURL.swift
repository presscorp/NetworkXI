//
//  MockURL.swift
//  
//
//  Created by Zhalgas on 07.03.2023.
//

import NetworkXI

struct MockURL: RequestURLExtensible {

    let path: String
    var host: String { "mock.host" }
}

extension MockURL {

    static let mock = Self("/mock")
}

