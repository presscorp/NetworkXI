//
//  RequestURL.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

public protocol RequestURL {

    /// Protocol type
    var scheme: String { get }

    /// Server host
    var host: String { get }

    /// Relative URL path
    var path: String { get }
}

public extension RequestURL {

    var scheme: String { "https://" }

    /// Absolute (full) URL path
    var absolutePath: String { scheme + host + path }
}

public typealias RequestURLExtensible = Equatable & PathInitializable & RequestURL

public extension RequestURL where Self: RequestURLExtensible {

    init(_ path: String) { self.init(path: path) }
}
