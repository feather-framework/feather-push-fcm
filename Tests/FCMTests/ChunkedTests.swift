//
//  ChunkedTests.swift
//  feather-push-fcm
//
//  Created by Binary Birds on 2023. 11. 19.

import Testing

@testable import FCM

@Suite
struct ChunkedTests {

    @Test
    func chunksArrays() {
        let array1 = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let result1 = array1.chunked(batchSize: 5)
        #expect(result1 == [[1, 2, 3, 4, 5], [6, 7, 8, 9]])

        let array2 = [1, 2]
        let result2 = array2.chunked(batchSize: 5)
        #expect(result2 == [[1, 2]])
    }

    @Test
    func chunksEmptyArray() {
        #expect([Int]().chunked(batchSize: 3).isEmpty)
    }

    @Test
    func chunksExactMultiple() {
        #expect([1, 2, 3, 4].chunked(batchSize: 2) == [[1, 2], [3, 4]])
    }

    @Test
    func nonPositiveBatchSizeProducesNoChunks() {
        #expect([1, 2, 3].chunked(batchSize: 0).isEmpty)
        #expect([1, 2, 3].chunked(batchSize: -1).isEmpty)
    }
}
