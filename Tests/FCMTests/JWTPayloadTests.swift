//
//  JWTPayloadTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import Foundation
import JWTKit
import Testing

@testable import FCM

@Suite
struct JWTPayloadTests {

    @Test
    func verifyAcceptsAnUnexpiredPayload() async throws {
        let payload = Self.payload(expiration: Date().addingTimeInterval(60))

        try await payload.verify(using: TestAlgorithm())
    }

    @Test
    func verifyRejectsAnExpiredPayload() async {
        let payload = Self.payload(expiration: Date().addingTimeInterval(-60))

        do {
            try await payload.verify(using: TestAlgorithm())
            Issue.record("Expected expired payload verification to fail")
        }
        catch {
            // Expected expiration claim verification failure.
        }
    }

    private static func payload(expiration: Date) -> FCMJWTPayload {
        let now = Date()
        return FCMJWTPayload(
            iss: .init(value: "client@example.com"),
            aud: .init(value: "https://example.com/token"),
            scope: "scope",
            iat: .init(value: now),
            exp: .init(value: expiration)
        )
    }
}

struct TestAlgorithm: JWTAlgorithm {
    var name: String { "test" }

    func sign<D: DataProtocol>(_ plaintext: D) throws -> [UInt8] {
        Array(plaintext)
    }

    func verify<S: DataProtocol, P: DataProtocol>(
        _ signature: S,
        signs plaintext: P
    ) throws -> Bool {
        Array(signature) == Array(plaintext)
    }
}
