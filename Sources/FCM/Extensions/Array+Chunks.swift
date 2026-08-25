//
//  Array+Chunks.swift
//  feather-push-fcm
//
//  Created by Tibor Bodecs on 2023. 11. 19.
//

extension Array {

    func chunked(batchSize size: Int) -> [[Element]] {
        guard size > 0 else {
            return []
        }
        return stride(from: 0, to: count, by: size)
            .map {
                Array(self[$0..<Swift.min($0 + size, count)])
            }
    }
}
