//
//  LivePushTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import AsyncHTTPClient
import FeatherPush
import FeatherPushFCM
import Foundation
import Logging
import Testing

@Suite
struct LivePushTests {

    /// Sends a real notification when explicitly enabled.
    //@Test
    func sendsNotificationToTopicUsingServerJSON() async throws {
        let topic = "testtopic"

        LoggingSystem.bootstrap(StreamLogHandler.standardOutput)

        let credentialsURL = try #require(
            Bundle.module.url(
                forResource: "FCM_server",
                withExtension: "json",
                subdirectory: "Resources"
            )
        )
        let credentialsData = try Data(contentsOf: credentialsURL)
        let httpClient = HTTPClient()

        do {
            let pushClient = try PushClientFCM(
                httpClient: httpClient,
                credentials: credentialsData
            )
            try await withLogger(Logger(label: "LivePushTests")) { _ in
                Logger.current.info(
                    "Sending FCM notification to topic \(topic)"
                )
                try await pushClient.send(
                    notification: PushNotification(
                        title: "Feather Push FCM test",
                        body: "Live topic delivery test.",
                        data: ["data1": "data1", "data2": "data2"],
                        delivery: .normal,
                        deepLink: "deeplink",
                        imageURL: "imageURL",
                        badge: 2,
                        sound: .default,
                        collapseID: "collapseID"
                    ),
                    to: .topic(topic)
                )
            }
        }
        catch {
            try? await httpClient.shutdown()
            throw error
        }

        try? await httpClient.shutdown()
    }
}
