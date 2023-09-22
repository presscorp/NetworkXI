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
        var response = (urlResponse: URLResponse?.none, data: Data?.none, error: Error?.none)

        guard let urlRequest = composeUrlRequest(from: request) else {
            return FailureResponse.unknown
        }

        if let logger = sessionInterface.logger {
            logger.log(request: urlRequest)
        }

        var responseIsMocked = false
        var responseIsCached = false
        defer {
            if let logger = sessionInterface.logger {
                logger.log(
                    request: urlRequest,
                    response: response.urlResponse as? HTTPURLResponse,
                    responseData: response.data,
                    error: response.error,
                    responseIsCached: responseIsCached,
                    responseIsMocked: responseIsMocked
                )
            }
        }

        // Return mocked response if available
        if let url = urlRequest.url, let mockResponse = request.mockResponse {
            responseIsMocked = true
            response = composeMock(from: url, mockResponse)
            return mockResponse
        }

        // Return cached response if possible
        if request.canRecieveCachedResponse,
           let cache = sessionInterface.cache,
           let cachedResponse = cache.cachedResponse(for: urlRequest) {
            responseIsCached = true
            (response.data, response.urlResponse) = (cachedResponse.data, cachedResponse.response)
            return composeResponse(from: response.urlResponse, response.data, response.error)
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

    public func make(_ request: NetworkRequest) async -> NetworkResponse {
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

    public func clearCachedResponse(for request: NetworkRequest) {
        guard let urlRequest = composeUrlRequest(from: request),
              let cache = sessionInterface.cache else {
            return
        }

        cache.removeCachedResponse(for: urlRequest)
    }

    public func clearAllCachedResponses() {
        guard let cache = sessionInterface.cache else {
            return
        }

        cache.removeAllCachedResponses()
    }
}
