//
//  FCMClientHelpersTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import AsyncHTTPClient
import Foundation
import NIOCore
import NIOHTTP1
import Testing

@testable import FCM

@Suite
struct FCMClientHelpersTests {

    @Test
    func encodingFailureIsInvalidRequestBody() {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        do {
            _ = try client.encodeRequestBody(FailingEncodable())
            Issue.record("Expected request body encoding to fail")
        }
        catch FCMClientError.invalidRequestBody {
            // Expected.
        }
        catch {
            Issue.record("Expected invalidRequestBody, got: \(error)")
        }
    }

    @Test
    func malformedTokenResponseIsInvalidResponse() {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        do {
            _ = try client.decodeToken(from: Data("not json".utf8))
            Issue.record("Expected token decoding to fail")
        }
        catch FCMClientError.invalidResponse {
            // Expected.
        }
        catch {
            Issue.record("Expected invalidResponse, got: \(error)")
        }
    }

    @Test
    func missingContentLengthIsAllowed() throws {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        try client.validateContentLength(nil, bodyLength: 4)
    }

    @Test
    func mismatchedContentLengthIsInvalidContentLength() {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        do {
            try client.validateContentLength("3", bodyLength: 4)
            Issue.record("Expected content length validation to fail")
        }
        catch FCMClientError.invalidContentLength {
            // Expected.
        }
        catch {
            Issue.record("Expected invalidContentLength, got: \(error)")
        }
    }

    @Test
    func readDataReturnsReadableBytes() throws {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        var buffer = ByteBufferAllocator().buffer(capacity: 0)
        buffer.writeString("response body")

        let data = try client.readData(from: buffer)

        #expect(data == Data("response body".utf8))
    }

    @Test
    func mapsUnauthorizedResponse() {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        let error = client.responseError(
            status: .unauthorized,
            body: Data("unauthorized".utf8)
        )

        guard case .unauthorized(let message) = error else {
            Issue.record("Expected unauthorized error")
            return
        }
        #expect(message == "unauthorized")
    }

    @Test
    func mapsRateLimitedResponse() {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        let error = client.responseError(
            status: .tooManyRequests,
            body: Data("rate limited".utf8)
        )

        guard case .rateLimited(let message) = error else {
            Issue.record("Expected rateLimited error")
            return
        }
        #expect(message == "rate limited")
    }

    @Test
    func mapsUnavailableResponse() {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        let error = client.responseError(
            status: .internalServerError,
            body: Data("unavailable".utf8)
        )

        guard case .unavailable(let message) = error else {
            Issue.record("Expected unavailable error")
            return
        }
        #expect(message == "unavailable")
    }

    @Test
    func preservesRejectedResponse() {
        let client = getClient()
        defer { try? client.client.syncShutdown() }
        let error = client.responseError(
            status: .badRequest,
            body: Data("bad request".utf8)
        )

        guard case .rejected(let status, let message) = error else {
            Issue.record("Expected rejected error")
            return
        }
        #expect(status == 400)
        #expect(message == "bad request")
    }

    private func getClient() -> FCMClient {
        FCMClient(
            client: HTTPClient(),
            credentials: .init(
                type: "service_account",
                projectId: "project",
                privateKeyId: "id",
                privateKey: "key",
                clientEmail: "client@example.com",
                clientId: "123",
                authURI: "https://example.com/auth",
                tokenURI: "https://example.com/token",
                authProviderX509CertURL: "https://example.com/provider",
                clientX509CertURL: "https://example.com/client",
                universeDomain: "example.com"
            )
        )
    }

    private struct FailingEncodable: Encodable {
        func encode(to encoder: Encoder) throws {
            throw EncodingError.invalidValue(
                self,
                .init(codingPath: [], debugDescription: "Test encoding failure")
            )
        }
    }
}
