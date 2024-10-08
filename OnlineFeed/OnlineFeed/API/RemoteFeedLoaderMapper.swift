//
//  RemoteFeedLoaderMapper.swift
//  OnlineFeed
//
//  Created by Vladislav Panev on 08.10.2024.
//

import Foundation

final class RemoteFeedLoaderMapper {
    private static let OK_RESPONSE = 200

    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard let root = try? JSONDecoder().decode(Root.self, from: data),
           response.statusCode == 200 else {
            throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
}

extension RemoteFeedLoaderMapper {
    struct Root: Codable {
        let items: [RemoteFeedItem]
    }
}
