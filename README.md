# Feather Push FCM

Firebase Cloud Messaging support for Feather Push using topic and device-token delivery.

[![Release: 1.0.0-beta.1](https://img.shields.io/badge/Release-1%2E0%2E0--beta%2E1-F05138)](https://github.com/feather-framework/feather-push-fcm/releases/tag/1.0.0-beta.1)

## Features

- `PushClient` implementation backed by FCM HTTP v1
- Topic and device-token delivery
- Firebase service-account authentication
- Deep-link and provider metadata support
- Swift 6 concurrency support

## Requirements

![Swift 6.1+](https://img.shields.io/badge/Swift-6%2E1%2B-F05138)

- Swift 6.1+
- macOS 15+, iOS 18+, tvOS 18+, watchOS 11+, or visionOS 2+
- A Firebase service account with FCM permissions

## Installation

```swift
.package(url: "https://github.com/feather-framework/feather-push-fcm", exact: "1.0.0-beta.1"),
```

Add `FeatherPushFCM` to the target dependencies:

```swift
.product(name: "FeatherPushFCM", package: "feather-push-fcm"),
```

## Usage

[![DocC API documentation](https://img.shields.io/badge/DocC-API_documentation-F05138)](https://feather-framework.github.io/feather-push-fcm/)

API documentation is available at the following link.

```swift
let client = PushClientFCM(
    httpClient: httpClient,
    credentials: credentials
)

let notification = PushNotification(
    title: "New message",
    body: "You have a new message.",
    deepLink: "my-app://messages/1"
)

try await client.send(notification: notification, to: .topic("messages"))

try await client.send(
    notification: notification,
    to: .deviceToken("device-registration-token")
)
```

The package uses `Logger.current` from [swift-log](https://github.com/apple/swift-log) for FCM request logging. Use `withLogger` to scope the logger for an operation; calls to `Logger.current` within that scope use the scoped logger.

## Development

- Build: `swift build`
- Test: `make test`
- Format: `make format`
- Check: `make check`

## Contributing

[Pull requests](https://github.com/feather-framework/feather-push-fcm/pulls) are welcome. Please keep changes focused and include tests for new logic.
