//
//  FCMClientError.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

/// Errors raised while communicating with Firebase Cloud Messaging.
public enum FCMClientError: Error {
    /// The request payload could not be encoded as JSON.
    case invalidRequestBody
    /// The response body length could not be read or validated.
    case invalidContentLength
    /// The provider response could not be decoded or understood.
    case invalidResponse
    /// The credentials or authorization were rejected by the provider.
    case unauthorized(String)
    /// The provider rate-limited the request.
    case rateLimited(String)
    /// The provider is temporarily unavailable.
    case unavailable(String)
    /// The provider rejected the request with an HTTP status and message.
    case rejected(status: Int, message: String)
    /// An unexpected underlying error occurred.
    case unknown(Error)
}
