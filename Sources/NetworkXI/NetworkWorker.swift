//
//  NetworkWorker.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

/// Worker class intended for making network requests
public class NetworkWorker: NetworkCompose {

    let sessionInterface: NetworkSessionInterface

    ///  Initializer that accepts session interface (adapter) argument
    /// - Parameter sessionInterface: Configured session interface
    public init(sessionInterface: NetworkSessionInterface) {
        self.sessionInterface = sessionInterface
    }

    private func makeRequest<T: NetworkRequest>(_ request: T) async -> NetworkResponse {
        var response = (urlResponse: URLResponse?.none, data: Data?.none, error: NSError?.none)

        guard let urlRequest = composeUrlRequest(from: request) else {
            return FailureResponse.unknown
        }

        if sessionInterface.loggingEnabled {
            NetworkLogger.log(request: urlRequest)
        }

        defer {
            if sessionInterface.loggingEnabled {
                NetworkLogger.log(
                    request: urlRequest,
                    response: response.urlResponse as? HTTPURLResponse,
                    responseData: response.data,
                    error: response.error
                )
            }
        }

        // Mocked response processing
        if let url = urlRequest.url, let mockResponse = request.mockResponse {
            response = composeMock(from: url, mockResponse)
            return mockResponse
        }

        guard sessionInterface.networkIsAvailable() else {
            return FailureResponse.notAvailable
        }

        do {
            if request is MultipartFormDataRequest, let bodyData = urlRequest.httpBody {
                (response.data, response.urlResponse) = try await sessionInterface.make(urlRequest, with: bodyData)
            } else {
                (response.data, response.urlResponse) = try await sessionInterface.make(urlRequest)
            }
        } catch {
            response.error = error as NSError?
        }

        return composeResponse(from: response.urlResponse, response.data, response.error)
    }
}

extension NetworkWorker: NetworkService {

    public func make<T: NetworkRequest>(_ request: T) async -> NetworkResponse {
        let response = await makeRequest(request)

        if let sessionRenewal = sessionInterface.sessionRenewal,
           sessionRenewal.renewIsNeeded(for: request, response) {
            do {
                try await sessionRenewal.renew()
            } catch {
                return response
            }

            return await makeRequest(request)
        }

        return response
    }
}
