//
//  StatusRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import NetworkXI

class StatusRequest: NetworkRequest {

    var url: RequestURL { HttpbinOrgURL.status(code) }
    var method: RequestMethod { .GET }
    var encoding: RequestContentEncoding { .url }
    var code = "200"
}
