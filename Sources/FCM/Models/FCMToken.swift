//
//  FCMToken.swift
//  feather-push-fcm
//
//  Created by Tibor Bodecs on 2023. 01. 16.
//

import Foundation

/// An OAuth access token returned by the Google authorization endpoint.
public struct FCMToken: Codable {

    enum CodingKeys: String, CodingKey {
        /// access token
        case accessToken = "access_token"
        /// token type
        case tokenType = "token_type"
        /// expire date
        case expiresIn = "expires_in"
        /// refresh token
        case refreshToken = "refresh_token"
        /// scope
        case scope = "scope"
        /// creation date
        case creationTime = "creation_time"
    }

    /// The bearer access token used for FCM requests.
    public let accessToken: String
    /// The token type, normally `Bearer`.
    public let tokenType: String?
    /// The lifetime of the access token in seconds.
    public let expiresIn: Int?
    /// An optional refresh token returned by the authorization service.
    public let refreshToken: String?
    /// The scopes granted to the access token.
    public let scope: String?
    /// The time at which the token was created.
    public let creationTime: Date?
}
