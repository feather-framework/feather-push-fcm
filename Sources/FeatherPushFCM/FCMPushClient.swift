//
//  FCMPushClient.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import AsyncHTTPClient
import FCM
import FeatherPush
import Foundation
import NIOCore

/// A `PushClient` implementation backed by Firebase Cloud Messaging.
public struct FCMPushClient: PushClient, Sendable {

    private let client: FCMClient

    /// Creates an FCM push client.
    public init(
        httpClient: HTTPClient,
        credentials: FCMCredentials,
        timeout: TimeAmount = .seconds(10)
    ) {
        self.client = FCMClient(
            client: httpClient,
            credentials: credentials,
            timeout: timeout
        )
    }

    /// Creates an FCM push client from Firebase service-account JSON data.
    public init(
        httpClient: HTTPClient,
        credentials: Data,
        timeout: TimeAmount = .seconds(10)
    ) throws {
        let decodedCredentials = try JSONDecoder()
            .decode(
                FCMCredentials.self,
                from: credentials
            )
        self.init(
            httpClient: httpClient,
            credentials: decodedCredentials,
            timeout: timeout
        )
    }

    /// Sends a notification to an FCM device token or subscribable topic.
    public func send(
        notification: PushNotification,
        to target: PushDeliveryTarget
    ) async throws(PushClientError) {
        let payload: FCMPayload
        switch target {
        case .topic(let topic):
            payload = try Self.makePayload(
                notification: notification,
                topic: topic
            )
        case .deviceToken(let token):
            payload = try Self.makePayload(
                notification: notification,
                token: token
            )
        }
        try await send(payload)
    }

    private func send(_ payload: FCMPayload) async throws(PushClientError) {
        do {
            try await client.send(payload)
        }
        catch let error {
            switch error {
            case .unauthorized:
                throw .unauthorized
            case .rateLimited:
                throw .rateLimited
            case .unavailable:
                throw .unavailable
            case .rejected(_, let message):
                throw .rejected(message)
            default:
                throw .unknown(error)
            }
        }
    }

    static func makePayload(
        notification: PushNotification,
        topic: String
    ) throws(PushClientError) -> FCMPayload {
        try makePayload(notification: notification, target: .topic(topic))
    }

    static func makePayload(
        notification: PushNotification,
        token: String
    ) throws(PushClientError) -> FCMPayload {
        try makePayload(notification: notification, target: .token(token))
    }

    private enum Target {
        case topic(String)
        case token(String)
    }

    private static func makePayload(
        notification: PushNotification,
        target: Target
    ) throws(PushClientError) -> FCMPayload {
        switch target {
        case .topic(let topic)
        where topic.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty:
            throw .invalidTopic
        case .token(let token)
        where token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty:
            throw .invalidDeviceToken
        default:
            break
        }

        var data = notification.data
        let reservedKeys = ["from", "message_type", "collapse_key"]
        guard
            !data.keys.contains(where: { key in
                reservedKeys.contains(key)
                    || key == "title"
                    || key == "body"
                    || key.hasPrefix("google.")
                    || key.hasPrefix("gcm.")
            })
        else {
            throw .invalidNotification
        }
        if let deepLink = notification.deepLink {
            data["deepLink"] = deepLink
        }
        if let imageURL = notification.imageURL {
            data["imageURL"] = imageURL
        }
        if let badge = notification.badge {
            data["badge"] = String(badge)
        }
        if let collapseID = notification.collapseID {
            data["collapseID"] = collapseID
        }

        let type: FCMPayload.Message.PushType
        switch notification.delivery {
        case .normal:
            type = .notification
        case .silent:
            type = .data
        }
        let isNotification = notification.delivery == .normal

        let soundName: String? =
            switch notification.sound {
            case .none:
                nil
            case .some(.default):
                "default"
            case .some(.named(let name)):
                name
            }
        let android: FCMPayload.Message.AndroidConfig? =
            isNotification
                && (soundName != nil || notification.collapseID != nil
                    || notification.imageURL != nil)
            ? .init(
                notification: .init(
                    sound: soundName,
                    tag: notification.collapseID,
                    image: notification.imageURL
                )
            )
            : nil
        let apns: FCMPayload.Message.APNsConfig? =
            isNotification
                && (soundName != nil || notification.badge != nil
                    || notification.collapseID != nil)
            ? .init(
                headers: notification.collapseID.map {
                    ["apns-collapse-id": $0]
                },
                payload: .init(
                    aps: .init(sound: soundName, badge: notification.badge)
                )
            )
            : nil

        let contentsData = notification.delivery == .silent ? data : [:]
        let messageData = notification.delivery == .normal ? data : nil

        let message: FCMPayload.Message
        switch target {
        case .topic(let topic):
            message = .init(
                topic: topic,
                type: type,
                contents: .init(
                    title: notification.title,
                    body: notification.body,
                    userInfo: contentsData
                ),
                data: messageData,
                android: android,
                apns: apns
            )
        case .token(let token):
            message = .init(
                token: token,
                type: type,
                contents: .init(
                    title: notification.title,
                    body: notification.body,
                    userInfo: contentsData
                ),
                data: messageData,
                android: android,
                apns: apns
            )
        }
        return FCMPayload(message: message)
    }
}
