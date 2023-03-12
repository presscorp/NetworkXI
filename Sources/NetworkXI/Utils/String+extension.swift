//
//  String+extension.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

extension String {

    var dictionary: [String: Any]? {
        guard let data = data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let dict = jsonObject as? [String: Any] else {
            return nil
        }
        return dict
    }
}
