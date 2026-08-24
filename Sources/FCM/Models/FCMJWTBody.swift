//
//  FCMJWTBody.swift
//  feather-push-fcm
//
//  Created by Tibor Bodecs on 19/11/2023.

import Foundation

struct FCMJWTBody: Encodable {

    enum CodingKeys: String, CodingKey {
        case grantType = "grant_type"
        case assertion
    }

    let grantType: String
    let assertion: String
}
