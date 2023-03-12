//
//  RequestContentEncoding.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

public enum RequestContentEncoding {

    case json, url

    var contentType: String {
        switch self {
        case .json: return "application/json; charset=UTF-8"
        case .url: return "application/x-www-form-urlencoded; charset=UTF-8"
        }
    }
}
