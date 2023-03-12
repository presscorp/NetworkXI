//
//  SessionAuthChallenge.swift
//  
//
//  Created by Zhalgas Baibatyr on 06.02.2023.
//

import Foundation

protocol SessionAuthChallenger: SessionAuthChallengeService {}

extension SessionAuthChallenger {

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        var disposition: URLSession.AuthChallengeDisposition
        if defaultSSLChallengeEnabled {
            disposition = .performDefaultHandling
        } else {
            disposition = .cancelAuthenticationChallenge
        }
        var urlCredential: URLCredential?

        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
        let serverTrust = challenge.protectionSpace.serverTrust {
            let isTrusted = SecTrustEvaluateWithError(serverTrust, nil)

            if isTrusted, let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                let serverCertificateData = SecCertificateCopyData(serverCertificate)
                let data = CFDataGetBytePtr(serverCertificateData)
                let size = CFDataGetLength(serverCertificateData)
                let serverCertData = NSData(bytes: data, length: size)

                for localCertData in sslCertificates {
                     guard serverCertData.isEqual(to: localCertData as Data) else { continue }
                     let credential = URLCredential(trust: serverTrust)
                     disposition = .useCredential
                     urlCredential = credential
                     break
                }
            }
        }

        return (disposition, urlCredential)
    }
}
