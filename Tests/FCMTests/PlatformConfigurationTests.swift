//
//  PlatformConfigurationTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import FCM
import Foundation
import Testing

@Suite
struct PlatformConfigurationTests {

    @Test
    func soundConfigurationEncodesForAndroidAndAPNs() throws {
        let payload = FCMPayload(
            message: .init(
                topic: "topic",
                type: .notification,
                contents: .init(title: "title", body: "body"),
                android: .init(notification: .init(sound: "default")),
                apns: .init(payload: .init(aps: .init(sound: "default")))
            )
        )

        let object =
            try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(payload)
            ) as? [String: Any]
        let message = object?["message"] as? [String: Any]
        let android = message?["android"] as? [String: Any]
        let androidNotification = android?["notification"] as? [String: Any]
        let apns = message?["apns"] as? [String: Any]
        let apnsPayload = apns?["payload"] as? [String: Any]
        let aps = apnsPayload?["aps"] as? [String: Any]

        #expect(androidNotification?["sound"] as? String == "default")
        #expect(aps?["sound"] as? String == "default")
    }

    @Test
    func soundConfigurationCanBeOmitted() throws {
        let payload = FCMPayload(
            message: .init(
                topic: "topic",
                type: .notification,
                contents: .init(title: "title", body: "body")
            )
        )

        let object =
            try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(payload)
            ) as? [String: Any]
        let message = object?["message"] as? [String: Any]

        #expect(message?["android"] == nil)
        #expect(message?["apns"] == nil)
    }

    @Test
    func normalMessageCarriesCustomDataSeparately() throws {
        let payload = FCMPayload(
            message: .init(
                topic: "topic",
                type: .notification,
                contents: .init(title: "title", body: "body"),
                data: ["deepLink": "my-app://message"]
            )
        )

        let object =
            try JSONSerialization.jsonObject(
                with: JSONEncoder().encode(payload)
            ) as? [String: Any]
        let message = object?["message"] as? [String: Any]
        let notification = message?["notification"] as? [String: Any]
        let data = message?["data"] as? [String: Any]

        #expect(notification?["title"] as? String == "title")
        #expect(notification?["body"] as? String == "body")
        #expect(data?["deepLink"] as? String == "my-app://message")
    }
}
