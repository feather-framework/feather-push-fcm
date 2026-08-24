//
//  PayloadMappingTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import FCM
import FeatherPush
import Foundation
import Testing

@testable import FeatherPushFCM

@Suite
struct PayloadMappingTests {

    @Test
    func normalNotificationMapsAllPlatformOptions() throws {
        let notification = PushNotification(
            title: "title",
            body: "body",
            data: ["custom": "value"],
            delivery: .normal,
            deepLink: "app://message",
            imageURL: "https://example.com/image.png",
            badge: 4,
            sound: .named("ding.wav"),
            collapseID: "collapse"
        )
        let payload = try FCMPushClient.makePayload(
            notification: notification,
            topic: "topic"
        )
        let message = try messageObject(from: payload)
        let notificationObject = try #require(
            message["notification"] as? [String: Any]
        )
        let data = try #require(message["data"] as? [String: Any])
        let android = try #require(message["android"] as? [String: Any])
        let androidNotification = try #require(
            android["notification"] as? [String: Any]
        )
        let apns = try #require(message["apns"] as? [String: Any])
        let headers = try #require(apns["headers"] as? [String: String])
        let aps = try #require(
            ((apns["payload"] as? [String: Any])?["aps"] as? [String: Any])
        )

        #expect(notificationObject["title"] as? String == "title")
        #expect(notificationObject["body"] as? String == "body")
        #expect(data["custom"] as? String == "value")
        #expect(data["deepLink"] as? String == "app://message")
        #expect(data["imageURL"] as? String == "https://example.com/image.png")
        #expect(data["badge"] as? String == "4")
        #expect(data["collapseID"] as? String == "collapse")
        #expect(androidNotification["sound"] as? String == "ding.wav")
        #expect(androidNotification["tag"] as? String == "collapse")
        #expect(
            androidNotification["image"] as? String
                == "https://example.com/image.png"
        )
        #expect(headers["apns-collapse-id"] == "collapse")
        #expect(aps["sound"] as? String == "ding.wav")
        #expect(aps["badge"] as? Int == 4)
    }

    @Test
    func silentNotificationKeepsDataInDataPayload() throws {
        let payload = try FCMPushClient.makePayload(
            notification: .init(
                title: "title",
                body: "body",
                data: ["custom": "value"],
                delivery: .silent,
                sound: .default
            ),
            topic: "topic"
        )
        let message = try messageObject(from: payload)
        let data = try #require(message["data"] as? [String: Any])

        #expect(data["title"] as? String == "title")
        #expect(data["body"] as? String == "body")
        #expect(data["custom"] as? String == "value")
        #expect(message["android"] == nil)
        #expect(message["apns"] == nil)
    }

    @Test
    func reservedDataKeysAreRejected() {
        do {
            _ = try FCMPushClient.makePayload(
                notification: .init(
                    title: "title",
                    body: "body",
                    data: ["google.test": "value"]
                ),
                topic: "topic"
            )
            Issue.record("Expected reserved FCM data key to be rejected")
        }
        catch .invalidNotification {
            // Expected.
        }
        catch {
            Issue.record("Expected invalidNotification, got: \(error)")
        }
    }

    @Test
    func emptyTopicIsRejectedBeforePayloadConstruction() {
        do {
            _ = try FCMPushClient.makePayload(
                notification: .init(title: "title", body: "body"),
                topic: " \n"
            )
            Issue.record("Expected empty topic to be rejected")
        }
        catch .invalidTopic {
            // Expected.
        }
        catch {
            Issue.record("Expected invalidTopic, got: \(error)")
        }
    }

    @Test
    func deviceTokenIsEncodedAsTheFcmTarget() throws {
        let payload = try FCMPushClient.makePayload(
            notification: .init(title: "title", body: "body"),
            token: "device-token"
        )
        let message = try messageObject(from: payload)

        #expect(message["token"] as? String == "device-token")
        #expect(message["topic"] == nil)
    }

    @Test
    func emptyDeviceTokenIsRejectedBeforePayloadConstruction() {
        do {
            _ = try FCMPushClient.makePayload(
                notification: .init(title: "title", body: "body"),
                token: " \n"
            )
            Issue.record("Expected empty device token to be rejected")
        }
        catch .invalidDeviceToken {
            // Expected.
        }
        catch {
            Issue.record("Expected invalidDeviceToken, got: \(error)")
        }
    }

    private func messageObject(from payload: FCMPayload) throws -> [String: Any]
    {
        let object =
            try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(payload)
            ) as? [String: Any]
        return try #require(object?["message"] as? [String: Any])
    }
}
