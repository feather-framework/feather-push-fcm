//
//  FCMCredentials.swift
//  feather-push-fcm
//
//  Created by Tibor Bodecs on 2023. 01. 16.
//

/// Firebase service-account credentials used to authenticate with FCM.
public struct FCMCredentials: Sendable, Codable {

    enum CodingKeys: String, CodingKey {
        /// type
        case type = "type"
        /// project id
        case projectId = "project_id"
        /// private key id
        case privateKeyId = "private_key_id"
        /// private key
        case privateKey = "private_key"
        /// client email
        case clientEmail = "client_email"
        /// client id
        case clientId = "client_id"
        /// auth uri
        case authURI = "auth_uri"
        /// token uri
        case tokenURI = "token_uri"
        /// auth provider x509 cert url
        case authProviderX509CertURL = "auth_provider_x509_cert_url"
        /// client x509 cert url
        case clientX509CertURL = "client_x509_cert_url"
        /// universe domain
        case universeDomain = "universe_domain"
    }

    /// The service-account type, normally `service_account`.
    public let type: String
    /// The Google Cloud project identifier.
    public let projectId: String
    /// The service-account private-key identifier.
    public let privateKeyId: String
    /// The PEM-encoded service-account private key.
    public let privateKey: String
    /// The service-account client email address.
    public let clientEmail: String
    /// The service-account client identifier.
    public let clientId: String
    /// The authorization endpoint from the service-account JSON.
    public let authURI: String
    /// The OAuth token endpoint used to obtain an access token.
    public let tokenURI: String
    /// The authentication-provider certificate URL.
    public let authProviderX509CertURL: String
    /// The client certificate URL.
    public let clientX509CertURL: String
    /// The Google API universe domain.
    public let universeDomain: String

    /// Creates credentials from the fields in a Firebase service-account JSON file.
    public init(
        type: String,
        projectId: String,
        privateKeyId: String,
        privateKey: String,
        clientEmail: String,
        clientId: String,
        authURI: String,
        tokenURI: String,
        authProviderX509CertURL: String,
        clientX509CertURL: String,
        universeDomain: String
    ) {
        self.type = type
        self.projectId = projectId
        self.privateKeyId = privateKeyId
        self.privateKey = privateKey
        self.clientEmail = clientEmail
        self.clientId = clientId
        self.authURI = authURI
        self.tokenURI = tokenURI
        self.authProviderX509CertURL = authProviderX509CertURL
        self.clientX509CertURL = clientX509CertURL
        self.universeDomain = universeDomain
    }
}
