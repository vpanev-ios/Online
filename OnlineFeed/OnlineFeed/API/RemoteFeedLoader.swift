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
                completion(RemoteFeedLoader.map(data, from: response))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}

private extension RemoteFeedLoader {
    static func map(_ data: Data, from response: HTTPURLResponse) -> LoadFeedResult<Error> {
        do {
            let remoteFeedItems = try RemoteFeedLoaderMapper.map(data, from: response)
            return .success(remoteFeedItems.toModel())
        } catch {
            return .failure(.invalidData)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModel() -> [FeedItem] {
        self.map {
            FeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.image)
        }
    }
}
