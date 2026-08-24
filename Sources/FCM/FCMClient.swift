//
//  FCMClient.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2025. 09. 23.

import AsyncHTTPClient
import Foundation
import JWTKit
import Logging
import NIOConcurrencyHelpers
import NIOCore
import NIOHTTP1
import NIOSSL
import NIOTLS

/// A low-level Firebase Cloud Messaging HTTP client.
public struct FCMClient: Sendable {

    let credentials: FCMCredentials
    let client: HTTPClient
    let timeout: TimeAmount

    /// Creates an FCM HTTP client.
    public init(
        client: HTTPClient,
        credentials: FCMCredentials,
        timeout: TimeAmount = .seconds(10)
    ) {
        self.client = client
        self.credentials = credentials
        self.timeout = timeout
    }

    /// Sends one FCM payload.
    public func send(_ message: FCMPayload) async throws(FCMClientError) {
        do {
            let token = try await requestToken()
            try await sendOneWithToken(message, token)
        }
        catch let error as FCMClientError {
            throw error
        }
        catch {
            throw .unknown(error)
        }
    }

    // MARK: - token

    private func requestToken() async throws -> FCMToken {
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

        let requestBodyData = try encodeRequestBody(requestBody)

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
            logger: Logger.current
        )
        let body = try await responseBody(response)
        guard response.status == .ok else {
            throw responseError(status: response.status, body: body)
        }
        return try decodeToken(from: body)
    }

    private func sendOneWithToken(
        _ message: FCMPayload,
        _ token: FCMToken
    ) async throws {
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        headers.add(name: "Authorization", value: "Bearer " + token.accessToken)

        let data = try encodeRequestBody(message)

        let url =
            "https://fcm.googleapis.com/v1/projects/\(credentials.projectId)/messages:send"
        var request = HTTPClientRequest(url: url)
        request.method = .POST
        request.headers = headers
        request.body = .bytes(data)

        let response = try await client.execute(
            request,
            timeout: timeout,
            logger: Logger.current
        )
        let body = try await responseBody(response)
        guard response.status == .ok else {
            throw responseError(status: response.status, body: body)
        }
    }

    private func responseBody(_ response: HTTPClientResponse) async throws
        -> Data
    {
        var buffer = ByteBuffer()
        for try await chunk in response.body {
            var chunk = chunk
            buffer.writeBuffer(&chunk)
        }
        let data = try readData(from: buffer)
        try validateContentLength(
            response.headers["Content-Length"].first,
            bodyLength: data.count
        )
        return data
    }
}
