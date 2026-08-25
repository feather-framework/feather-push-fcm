//
//  PayloadTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2023. 11. 19.

import FCM
import Foundation
import Testing

@Suite
struct PayloadTests {

    @Test
    func basicEncoding() throws {
        let payload = FCMPayload(
            message: .init(
                topic: "topic",
                type: .data,
                contents: .init(
                    title: "title",
                    body: "body",
                    userInfo: ["foo": "bar"]
                )
            )
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(payload)
        let json = String(decoding: data, as: UTF8.self)
        let expected = """
            {
              "message" : {
                "data" : {
                  "body" : "body",
                  "foo" : "bar",
                  "title" : "title"
                },
                "topic" : "topic"
              }
            }
            """
        #expect(json == expected)
    }

    @Test
    func emptyUserInfoEncoding() throws {
        let payload = FCMPayload(
            message: .init(
                topic: "topic",
                type: .notification,
                contents: .init(
                    title: "title",
                    body: "body"
                )
            )
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(payload)
        let json = String(decoding: data, as: UTF8.self)
        let expected = """
            {
              "message" : {
                "notification" : {
                  "body" : "body",
                  "title" : "title"
                },
                "topic" : "topic"
              }
            }
            """
        #expect(json == expected)
    }

    @Test
    func userInfoCannotOverwriteTitleOrBody() throws {
        let payload = FCMPayload(
            message: .init(
                topic: "topic",
                type: .notification,
                contents: .init(
                    title: "title",
                    body: "body",
                    userInfo: ["title": "override"]
                )
            )
        )

        do {
            _ = try JSONEncoder().encode(payload)
            Issue.record("Expected duplicate coding key to fail")
        }
        catch let error as EncodingError {
            guard case .invalidValue = error else {
                Issue.record("Expected invalidValue encoding error")
                return
            }
        }
    }
}
