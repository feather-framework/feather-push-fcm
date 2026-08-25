//
//  FCMPayload.swift
//  feather-push-fcm
//
//  Created by Tibor Bodecs on 2023. 01. 16.
//

/// A Firebase Cloud Messaging HTTP v1 request payload.
public struct FCMPayload: Encodable {

    /// The message body sent to FCM.
    public struct Message: Encodable {

        /// The type of content carried by the FCM message.
        public enum PushType: String, Encodable {
            /// Data-only content for silent delivery.
            case data
            /// User-visible notification content.
            case notification
        }

        /// Android-specific FCM configuration.
        public struct AndroidConfig: Encodable {
            /// Android notification options.
            public let notification: AndroidNotification

            /// Creates an Android configuration.
            public init(notification: AndroidNotification) {
                self.notification = notification
            }
        }

        /// Android notification options.
        public struct AndroidNotification: Encodable {
            /// The sound resource name, or `default`.
            public let sound: String?
            /// The Android notification tag.
            public let tag: String?
            /// The Android notification image.
            public let image: String?

            /// Creates Android notification options.
            public init(
                sound: String? = nil,
                tag: String? = nil,
                image: String? = nil
            ) {
                self.sound = sound
                self.tag = tag
                self.image = image
            }
        }

        /// APNs-specific FCM configuration.
        public struct APNsConfig: Encodable {
            /// APNs request headers.
            public let headers: [String: String]?
            /// APNs payload.
            public let payload: APNsPayload

            /// Creates an APNs configuration.
            public init(
                headers: [String: String]? = nil,
                payload: APNsPayload
            ) {
                self.headers = headers
                self.payload = payload
            }
        }

        /// APNs payload.
        public struct APNsPayload: Encodable {
            /// Apple Push Notification service dictionary.
            public let aps: APS

            /// Creates an APNs payload.
            public init(aps: APS) {
                self.aps = aps
            }
        }

        /// Apple Push Notification service options.
        public struct APS: Encodable {
            /// The sound name, or `default`.
            public let sound: String?
            /// The application badge number.
            public let badge: Int?

            /// Creates Apple notification options.
            public init(sound: String? = nil, badge: Int? = nil) {
                self.sound = sound
                self.badge = badge
            }
        }

        /// Notification content and application data carried by the message.
        public struct Contents: Encodable {

            struct CodingKeys: CodingKey, ExpressibleByStringLiteral {

                static let title: Self = "title"
                static let body: Self = "body"

                var stringValue: String
                var intValue: Int?

                init(stringLiteral value: StringLiteralType) {
                    self.stringValue = value
                }

                init?(stringValue: String) {
                    self.stringValue = stringValue
                }

                init?(intValue: Int) {
                    nil
                }
            }

            /// The notification title.
            public let title: String
            /// The notification body.
            public let body: String
            /// Additional application data included in the message content.
            public let userInfo: [String: String]

            /// Creates notification contents.
            public init(
                title: String,
                body: String,
                userInfo: [String: String] = [:]
            ) {
                self.title = title
                self.body = body
                self.userInfo = userInfo
            }

            /// Encodes the title, body, and custom application data.
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(self.title, forKey: CodingKeys.title)
                try container.encode(self.body, forKey: CodingKeys.body)

                for (k, value) in userInfo {
                    guard let key = CodingKeys(stringValue: k) else {
                        continue
                    }
                    guard
                        key.stringValue != CodingKeys.title.stringValue,
                        key.stringValue != CodingKeys.body.stringValue
                    else {
                        throw EncodingError.invalidValue(
                            value,
                            .init(
                                codingPath: [key],
                                debugDescription: "Duplicate coding keys."
                            )
                        )
                    }
                    try container.encode(value, forKey: key)
                }
            }

        }

        struct CodingKeys: CodingKey, ExpressibleByStringLiteral {

            static let topic: Self = "topic"
            static let token: Self = "token"
            static let data: Self = "data"
            static let android: Self = "android"
            static let apns: Self = "apns"

            var stringValue: String
            var intValue: Int?

            init(_ value: String) {
                self.stringValue = value
            }

            init(stringLiteral value: StringLiteralType) {
                self.stringValue = value
            }

            init?(stringValue: String) {
                self.stringValue = stringValue
            }

            init?(intValue: Int) {
                nil
            }
        }

        /// The FCM topic target, when sending to a topic.
        public let topic: String?
        /// The FCM registration-token target, when sending to one device.
        public let token: String?
        /// The content type used for the message body.
        public let type: PushType
        /// The notification contents included in the message.
        public let contents: Contents
        /// Custom application data.
        public let data: [String: String]?
        /// Android-specific configuration.
        public let android: AndroidConfig?
        /// APNs-specific configuration.
        public let apns: APNsConfig?

        /// Creates an FCM topic message.
        public init(
            topic: String,
            type: PushType,
            contents: Contents,
            data: [String: String]? = nil,
            android: AndroidConfig? = nil,
            apns: APNsConfig? = nil
        ) {
            self.topic = topic
            self.token = nil
            self.type = type
            self.contents = contents
            self.data = data
            self.android = android
            self.apns = apns
        }

        /// Creates an FCM device-token message.
        public init(
            token: String,
            type: PushType,
            contents: Contents,
            data: [String: String]? = nil,
            android: AndroidConfig? = nil,
            apns: APNsConfig? = nil
        ) {
            self.topic = nil
            self.token = token
            self.type = type
            self.contents = contents
            self.data = data
            self.android = android
            self.apns = apns
        }

        /// Encodes the message using FCM content keys.
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(self.topic, forKey: CodingKeys.topic)
            try container.encodeIfPresent(self.token, forKey: CodingKeys.token)
            try container.encode(self.contents, forKey: .init(type.rawValue))
            if case .notification = self.type {
                try container.encodeIfPresent(
                    self.data,
                    forKey: CodingKeys.data
                )
            }
            try container.encodeIfPresent(
                self.android,
                forKey: CodingKeys.android
            )
            try container.encodeIfPresent(self.apns, forKey: CodingKeys.apns)
        }
    }

    /// The FCM message request body.
    public let message: Message

    /// Creates an FCM request payload.
    public init(message: Message) {
        self.message = message
    }
}
