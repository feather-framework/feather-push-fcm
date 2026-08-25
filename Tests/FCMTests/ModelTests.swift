//
//  ModelTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import FCM
import Foundation
import Testing

@Suite
struct ModelTests {

    @Test
    func credentialsRoundTripWithFirebaseCodingKeys() throws {
        let credentials = FCMCredentials(
            type: "service_account",
            projectId: "project",
            privateKeyId: "key-id",
            privateKey: "private-key",
            clientEmail: "client@example.com",
            clientId: "123",
            authURI: "https://accounts.google.com/o/oauth2/auth",
            tokenURI: "https://oauth2.googleapis.com/token",
            authProviderX509CertURL: "https://example.com/provider",
            clientX509CertURL: "https://example.com/client",
            universeDomain: "googleapis.com"
        )

        let data = try JSONEncoder().encode(credentials)
        let decoded = try JSONDecoder().decode(FCMCredentials.self, from: data)
        #expect(decoded.type == credentials.type)
        #expect(decoded.projectId == credentials.projectId)
        #expect(decoded.privateKeyId == credentials.privateKeyId)
        #expect(decoded.privateKey == credentials.privateKey)
        #expect(decoded.clientEmail == credentials.clientEmail)
        #expect(decoded.clientId == credentials.clientId)
        #expect(decoded.authURI == credentials.authURI)
        #expect(decoded.tokenURI == credentials.tokenURI)
        #expect(
            decoded.authProviderX509CertURL
                == credentials.authProviderX509CertURL
        )
        #expect(decoded.clientX509CertURL == credentials.clientX509CertURL)
        #expect(decoded.universeDomain == credentials.universeDomain)
    }

    @Test
    func tokenDecodesOptionalFields() throws {
        let json = """
            {"access_token":"token","token_type":"Bearer","expires_in":3600,"refresh_token":"refresh","scope":"scope","creation_time":"2026-08-18T12:00:00Z"}
            """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let token = try decoder.decode(FCMToken.self, from: Data(json.utf8))
        #expect(token.accessToken == "token")
        #expect(token.tokenType == "Bearer")
        #expect(token.expiresIn == 3600)
        #expect(token.refreshToken == "refresh")
        #expect(token.scope == "scope")
        #expect(token.creationTime != nil)
    }

    @Test
    func tokenDecodesWithOnlyRequiredField() throws {
        let token = try JSONDecoder()
            .decode(
                FCMToken.self,
                from: Data(#"{"access_token":"token"}"#.utf8)
            )
        #expect(token.accessToken == "token")
        #expect(token.tokenType == nil)
        #expect(token.expiresIn == nil)
    }
}
