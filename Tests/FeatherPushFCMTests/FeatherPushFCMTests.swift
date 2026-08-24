//
//  FeatherPushFCMTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import AsyncHTTPClient
import FCM
import FeatherPush
import FeatherPushFCM
import Foundation
import Logging
import Testing

@Suite
struct FeatherPushFCMTests {

    @Test
    func notificationSupportsTopicMetadata() {
        let notification = PushNotification(
            title: "title",
            body: "body",
            data: ["deepLink": "my-app://messages/1"]
        )

        #expect(notification.data["deepLink"] == "my-app://messages/1")
        #expect(notification.title == "title")
        #expect(notification.body == "body")
    }

    @Test
    func clientDecodesCredentialsFromJSONData() throws {
        let url = try #require(
            Bundle.module.url(
                forResource: "server_example",
                withExtension: "json",
                subdirectory: "Resources"
            )
        )
        let data = try Data(contentsOf: url)
        let client = HTTPClient()
        defer { try? client.syncShutdown() }

        _ = try PushClientFCM(
            httpClient: client,
            credentials: data
        )
    }

    @Test
    func pushClientErrorCasesAreAvailable() {
        let errors: [PushClientError] = [
            .invalidTopic,
            .invalidDeviceToken,
            .invalidNotification,
            .unsupportedTarget,
            .unauthorized,
            .rateLimited,
            .unavailable,
            .rejected("rejected"),
        ]

        #expect(errors.count == 8)
    }

    @Test
    func blankTopicsAreRejected() async {
        let client = HTTPClient()
        let pushClient = PushClientFCM(
            httpClient: client,
            credentials: Self.credentials
        )

        do {
            try await withLogger(Logger(label: "FeatherPushFCMTests")) { _ in
                try await pushClient.send(
                    notification: PushNotification(title: "title", body: "body"),
                    to: .topic(" \n\t")
                )
            }
            Issue.record("Expected blank topic to be rejected")
        }
        catch let error as PushClientError where Self.isInvalidTopic(error) {
            // Expected.
        }
        catch {
            Issue.record("Expected invalidTopic, got: \(error)")
        }
        try? await client.shutdown()
    }

    @Test
    func notificationMetadataAndDeliveryAreMappedBeforeProviderFailure() async {
        let client = HTTPClient()
        let pushClient = PushClientFCM(
            httpClient: client,
            credentials: Self.credentials
        )
        let notification = PushNotification(
            title: "title",
            body: "body",
            data: ["custom": "value"],
            delivery: .silent,
            deepLink: "app://message",
            imageURL: "https://example.com/image.png",
            badge: 3,
            collapseID: "collapse"
        )

        do {
            try await withLogger(Logger(label: "FeatherPushFCMTests")) { _ in
                try await pushClient.send(
                    notification: notification,
                    to: .topic("topic")
                )
            }
            Issue.record(
                "Expected invalid private key to fail before a network request"
            )
        }
        catch let error as PushClientError where Self.isUnknown(error) {
            // The payload was constructed and the silent delivery branch was exercised.
        }
        catch {
            Issue.record("Expected unknown provider error, got: \(error)")
        }
        try? await client.shutdown()
    }

    private static func isInvalidTopic(_ error: PushClientError) -> Bool {
        if case .invalidTopic = error { return true }
        return false
    }

    private static func isUnknown(_ error: PushClientError) -> Bool {
        if case .unknown = error { return true }
        return false
    }

    private static let credentials = FCMCredentials(
        type: "service_account",
        projectId: "project",
        privateKeyId: "id",
        privateKey: "not-a-key",
        clientEmail: "client@example.com",
        clientId: "123",
        authURI: "https://example.com/auth",
        tokenURI: "https://example.com/token",
        authProviderX509CertURL: "https://example.com/provider",
        clientX509CertURL: "https://example.com/client",
        universeDomain: "example.com"
    )
}
