//
//  RemoteFeedLoader.swift
//  OnlineFeed
//
//  Created by Vladislav Panev on 02.10.2024.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    public typealias Response = LoadFeedResult<Error>

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private let url: URL
    private let client: HTTPClient

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (LoadFeedResult<Error>) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                if let items = try? JSONDecoder().decode(Item.self, from: data),
                   response.statusCode == 200 {
                    completion(.success(items.items.map { $0.feedItem }))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private extension RemoteFeedLoader {
    struct Item: Codable {
        let items: [InnerItem]
        
        struct InnerItem: Codable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
            
            var feedItem: FeedItem {
                FeedItem(
                    id: id,
                    description: description,
                    location: location,
                    imageURL: image
                )
            }
        }
    }
}
