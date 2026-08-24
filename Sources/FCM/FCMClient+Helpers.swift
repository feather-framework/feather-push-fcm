//
//  FCMClient+Helpers.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2026. 08. 24.

import Foundation
import NIOCore
import NIOHTTP1

extension FCMClient {

    func encodeRequestBody<T: Encodable>(
        _ value: T
    ) throws(FCMClientError) -> Data {
        do {
            return try JSONEncoder().encode(value)
        }
        catch {
            throw .invalidRequestBody
        }
    }

    func decodeToken(from data: Data) throws(FCMClientError) -> FCMToken {
        do {
            return try JSONDecoder().decode(FCMToken.self, from: data)
        }
        catch {
            throw .invalidResponse
        }
    }

    func readData(from buffer: ByteBuffer) throws(FCMClientError) -> Data {
        guard
            let bytes = buffer.getBytes(
                at: buffer.readerIndex,
                length: buffer.readableBytes
            )
        else {
            throw .invalidContentLength
        }
        return Data(bytes)
    }

    func validateContentLength(
        _ value: String?,
        bodyLength: Int
    ) throws(FCMClientError) {
        guard let value else {
            return
        }
        guard let contentLength = Int(value), contentLength == bodyLength else {
            throw .invalidContentLength
        }
    }

    func responseError(
        status: HTTPResponseStatus,
        body: Data
    ) -> FCMClientError {
        let message = String(decoding: body, as: UTF8.self)
        switch status.code {
        case 401, 403:
            return .unauthorized(message)
        case 429:
            return .rateLimited(message)
        case 500...599:
            return .unavailable(message)
        default:
            return .rejected(status: Int(status.code), message: message)
        }
    }
}
