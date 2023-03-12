//
//  UploadRequest.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import NetworkXI

class UploadRequest: MultipartFormDataRequest {

    var url: RequestURL { HttpbinOrgURL.post }
    let paramsArray: [MultipartFormDataParams]
    var boundary: String

    required init(paramsArray: [MultipartFormDataParams]) {
        self.paramsArray = paramsArray
        self.boundary = Self.generateBoundary()
    }
}
