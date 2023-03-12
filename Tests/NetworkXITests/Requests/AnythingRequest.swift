//
//  AnythingRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import NetworkXI

class AnythingRequest: NetworkRequest {

    var url: RequestURL { HttpbinOrgURL.anything }
    var method: RequestMethod { .POST }
    var encoding: RequestContentEncoding { .json }
    let parameters: [String: Any]

    init(parameters: [String: Any]) {
        self.parameters = parameters
    }
}
