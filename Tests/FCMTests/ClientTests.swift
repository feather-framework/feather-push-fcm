//
//  ClientTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import AsyncHTTPClient
import FCM
import Foundation
import Logging
import Testing

@Suite
struct ClientTests {

    @Test
    func invalidPrivateKeyIsWrappedAsUnknownError() async {
        let client = HTTPClient()
        let fcm = FCMClient(
            client: client,
            credentials: Self.credentials(privateKey: "not-a-key")
        )

        do {
            try await withLogger(Logger(label: "FCMTests")) { _ in
                try await fcm.send(Self.payload())
            }
            Issue.record("Expected malformed private key to fail")
        }
        catch FCMClientError.unknown {
            // The public API deliberately hides third-party signing errors.
        }
        catch {
            Issue.record("Expected FCMClientError.unknown, got: \(error)")
        }
        try? await client.shutdown()
    }

    private static func payload() -> FCMPayload {
        FCMPayload(
            message: .init(
                topic: "topic",
                type: .data,
                contents: .init(title: "title", body: "body")
            )
        )
    }

    private static func credentials(privateKey: String) -> FCMCredentials {
        .init(
            type: "service_account",
            projectId: "project",
            privateKeyId: "id",
            privateKey: privateKey,
            clientEmail: "client@example.com",
            clientId: "123",
            authURI: "https://example.com/auth",
            tokenURI: "https://example.com/token",
            authProviderX509CertURL: "https://example.com/provider",
            clientX509CertURL: "https://example.com/client",
            universeDomain: "example.com"
        )
    }

}
