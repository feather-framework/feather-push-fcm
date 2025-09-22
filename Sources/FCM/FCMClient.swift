import AsyncHTTPClient
import Foundation
import JWTKit
import Logging
import NIOConcurrencyHelpers
import NIOCore
import NIOHTTP1
import NIOSSL
import NIOTLS
import NIOFoundationCompat

/// FCMClientError
public enum FCMClientError: Error {
    case invalidRequestBody
    case invalidContentLength
    case invalidResponse
}

/// fcm client
public struct FCMClient {

    var credentials: FCMCredentials
    let client: HTTPClient
    let timeout: TimeAmount
    let logger: Logger

    /// fcm client init
    public init(
        client: HTTPClient,
        credentials: FCMCredentials,
        timeout: TimeAmount = .seconds(10),
        logger: Logger = .init(label: "fcm")
    ) {
        self.client = client
        self.credentials = credentials
        self.timeout = timeout
        self.logger = logger
    }

    /// fcm client send
    public func send(_ messages: [FCMPayload]) async throws {
        guard !messages.isEmpty else {
            return
        }

        let token = try await requestToken()
        for msg in messages {
            _ = try await sendOneWithToken(msg, token)
            //TODO: add better error handling
        }
    }

    // MARK: - token

    func requestToken() async throws -> FCMToken {
        let now = Date()
        let jwtPayload = FCMJWTPayload(
            iss: .init(value: credentials.clientEmail),
            aud: .init(value: credentials.tokenURI),
            scope: "https://www.googleapis.com/auth/firebase.messaging",
            iat: .init(value: now),
            exp: .init(value: now.addingTimeInterval(3600))
        )

        let pk = try Insecure.RSA.PrivateKey(pem: credentials.privateKey)
        let keys = await JWTKeyCollection()
            .add(rsa: pk, digestAlgorithm: .sha256)
        let jwt = try await keys.sign(jwtPayload)

        let requestBody = FCMJWTBody(
            grantType: "urn:ietf:params:oauth:grant-type:jwt-bearer",
            assertion: jwt
        )

        let encoder = JSONEncoder()
        let requestBodyData = try encoder.encode(requestBody)

        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")

        var request = HTTPClientRequest(
            url: credentials.tokenURI
        )
        request.method = .POST
        request.headers = headers
        request.body = .bytes(requestBodyData)

        let response = try await client.execute(
            request,
            timeout: timeout,
            logger: logger
        )
        guard response.status == .ok else {
            throw FCMClientError.invalidResponse
        }
        var buffer = ByteBuffer()
        for try await chunk in response.body {
            var chunk = chunk
            buffer.writeBuffer(&chunk)
        }
        let decoder = JSONDecoder()
        return try decoder.decode(FCMToken.self, from: buffer)
    }

    // MARK: - helpers

    private func sendOneWithToken(
        _ message: FCMPayload,
        _ token: FCMToken
    ) async throws -> HTTPResponseStatus {
        //let token = try await requestToken()
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Authorization", value: "Bearer " + token.accessToken)

        let encoder = JSONEncoder()
        let data = try encoder.encode(message)
        
        let url =
            "https://fcm.googleapis.com/v1/projects/\(credentials.projectId)/messages:send"
        var request = HTTPClientRequest(url: url)
        request.method = .POST
        request.headers = headers
        request.body = .bytes(data)

        let response = try await client.execute(
            request,
            timeout: timeout,
            logger: logger
        )
        return response.status
    }
    
    // no longer exist batch
    //private func send500(
    //    _ batch: [FCMPayload],
    //    _ token: FCMToken
    //) async throws {
    //    var headers = HTTPHeaders()
    //    headers.add(name: "Authorization", value: "Bearer " + token.accessToken)
    //    headers.add(
    //        name: "Content-Type",
    //        value: "multipart/mixed; boundary=subrequest_boundary"
    //    )
    //
    //    let encoder = JSONEncoder()
    //    let body =
    //        try batch.compactMap { message -> String? in
    //            let data = try encoder.encode(message)
    //            guard let json = String(data: data, encoding: .utf8) else {
    //                return nil
    //            }
    //            return """
    //                --subrequest_boundary
    //                Content-Type: application/http
    //                Content-Transfer-Encoding: binary
    //
    //                POST /v1/projects/\(credentials.projectId)/messages:send
    //                Content-Type: application/json
    //                accept: application/json
    //
    //                \(json)
    //
    //                --subrequest_boundary--
    //                """
    //        }
    //        .joined(separator: "")
    //
    //    guard let data = body.data(using: .utf8) else {
    //        throw FCMClientError.invalidRequestBody
    //    }
    //
    //    var httpClientRequest = HTTPClientRequest(
    //        url: "https://fcm.googleapis.com/batch"
    //    )
    //    httpClientRequest.method = .POST
    //    httpClientRequest.headers = headers
    //    httpClientRequest.body = .bytes(data)
    //
    //    let response = try await client.execute(
    //        httpClientRequest,
    //        timeout: timeout,
    //        logger: logger
    //    )
    //    guard response.status == .ok else {
    //        // TODO: check body value...
    //        throw FCMClientError.invalidResponse
    //    }
    //}
    
}
