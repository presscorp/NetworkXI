//
//  NetworkCompose.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

protocol NetworkCompose {

    var sessionInterface: NetworkSessionInterface { get }
}

extension NetworkCompose {

    func composeUrlRequest<T: NetworkRequest>(from request: T) -> URLRequest? {
        if let multipartRequest = request as? MultipartFormDataRequest {
            return compose(from: multipartRequest)
        } else {
            return compose(from: request)
        }
    }

    private func compose(from request: NetworkRequest) -> URLRequest? {
        // Compose URL
        let composedUrl: URL
        if request.encodesParametersInURL {
            var urlComponents = URLComponents(string: request.url.absolutePath)
            urlComponents?.percentEncodedQueryItems = request.parameters.compactMap { name, anyValue -> URLQueryItem? in
                guard var value = (anyValue as? CustomStringConvertible)?.description else { return nil }
                if value.removingPercentEncoding == value,
                   let percentEncodedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                    value = percentEncodedValue
                }
                return URLQueryItem(name: name, value: value)
            }
            guard let url = urlComponents?.url else { return nil }
            composedUrl = url
        } else {
            guard let url = URL(string: request.url.absolutePath) else { return nil }
            composedUrl = url
        }
        
        // Compose request
        var urlRequest = URLRequest(url: composedUrl)
        urlRequest.httpMethod = request.method.rawValue
        if let timeoutInterval = request.timeoutInterval {
            urlRequest.timeoutInterval = timeoutInterval
        }

        // Compose headers
        var allHTTPHeaderFields = [String: String]()
        allHTTPHeaderFields["Content-Type"] = request.encoding.contentType
        sessionInterface.additionalHTTPHeaders.forEach { allHTTPHeaderFields[$0] = $1 }
        request.edit(httpHeaders: &allHTTPHeaderFields)
        urlRequest.allHTTPHeaderFields = allHTTPHeaderFields

        // Compose body
        if let httpBody = request.httpBody {
            urlRequest.httpBody = httpBody
        } else if !request.encodesParametersInURL && !request.parameters.isEmpty {
            switch request.encoding {
            case .json:
                let jsonObject = request.parameters.compactMapValues { $0 }
                guard JSONSerialization.isValidJSONObject(jsonObject),
                      let data = try? JSONSerialization.data(withJSONObject: jsonObject) else {
                    return nil
                }
                urlRequest.httpBody = data
            case .url:
                let parameters = request.parameters.reduce("") { (result: String, pair: (String, Any)) -> String in
                    guard let value = pair.1 as? CustomStringConvertible else { return "" }
                    return result + (result.isEmpty ? "" : "&") + pair.0 + "=" + value.description
                }
                urlRequest.httpBody = parameters.data(using: .utf8)
            }
        }

        return urlRequest
    }

    /// Compose url request to send multipart data
    /// - Parameter request: Multipart form data request
    /// - Returns: URLRequest object
    private func compose(from request: MultipartFormDataRequest) -> URLRequest? {
        // Compose URL
        let composedUrl: URL
        if request.encodesParametersInURL {
            var urlComponents = URLComponents(string: request.url.absolutePath)
            urlComponents?.queryItems = request.parameters.compactMap { name, value -> URLQueryItem? in
                guard let value = (value as? CustomStringConvertible)?.description else { return nil }
                return URLQueryItem(name: name, value: value)
            }
            guard let url = urlComponents?.url else { return nil }
            composedUrl = url
        } else {
            guard let url = URL(string: request.url.absolutePath) else { return nil }
            composedUrl = url
        }

        // Compose request
        var urlRequest = URLRequest(url: composedUrl)
        urlRequest.httpMethod = request.method.rawValue
        if let timeoutInterval = request.timeoutInterval {
            urlRequest.timeoutInterval = timeoutInterval
        }

        // Form headers
        var allHTTPHeaderFields = [String: String]()
        allHTTPHeaderFields["Content-Type"] = "multipart/form-data; boundary=" + request.boundary
        sessionInterface.additionalHTTPHeaders.forEach { allHTTPHeaderFields[$0] = $1 }
        request.edit(httpHeaders: &allHTTPHeaderFields)
        urlRequest.allHTTPHeaderFields = allHTTPHeaderFields

        // Set body
        urlRequest.httpBody = request.httpBody

        return urlRequest
    }

    func composeResponse(from urlResponse: URLResponse?, _ data: Data?, _ error: NSError?) -> NetworkResponse {
        guard let httpUrlResponse = urlResponse as? HTTPURLResponse else {
            if let error = error as NSError? {
                switch error.code {
                case NSURLErrorCancelled: return FailureResponse.cancelled
                case NSURLErrorTimedOut: return FailureResponse.timeout
                default: break
                }
            }
            return FailureResponse.unknown
        }

        guard 200..<300 ~= httpUrlResponse.statusCode else {
            return FailureResponse(
                statusCode: httpUrlResponse.statusCode,
                error: .serverSide(error),
                body: data,
                headers: httpUrlResponse.allHeaderFields
            )
        }

        return SuccessResponse(
            statusCode: httpUrlResponse.statusCode,
            body: data,
            headers: httpUrlResponse.allHeaderFields
        )
    }

    func composeMock(
        from url: URL,
        _ response: NetworkResponse
    ) -> (urlResponse: URLResponse?, data: Data?, error: NSError?) {
        var headerFields = [String: String]()
        response.headers.forEach { key, value in
            guard let key = key as? String, let value = value as? String else { return }
            headerFields[key] = value
        }

        let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: response.statusCode,
            httpVersion: nil,
            headerFields: headerFields
        )

        return (urlResponse, response.body, error: response.error?.error)
    }
}
