//
//  HttpbinOrgURL.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import NetworkXI

struct HttpbinOrgURL: RequestURLExtensible {

    let path: String
    var host: String { "httpbin.org" }
}

extension HttpbinOrgURL {

    static let anything = Self("/anything")

    static let post = Self("/post")

    static func status(_ code: String) -> Self {
        Self("/status/" + code)
    }
}
