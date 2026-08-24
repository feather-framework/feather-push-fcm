//
//  FCMJWTPayload.swift
//  feather-push-fcm
//
//  Created by Tibor Bodecs on 2023. 01. 16.
//

import JWTKit

/// The JWT payload used to authenticate with Firebase Cloud Messaging.
struct FCMJWTPayload: JWTPayload {

    var iss: IssuerClaim
    var aud: AudienceClaim
    let scope: String
    var iat: IssuedAtClaim
    var exp: ExpirationClaim

    /// Verifies that the JWT has not expired.
    public func verify(using algorithm: some JWTAlgorithm)
        async throws
    {
        try self.exp.verifyNotExpired()
    }
}
