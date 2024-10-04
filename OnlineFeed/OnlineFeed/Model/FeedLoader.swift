//
//  FeedLoader.swift
//  OnlineFeed
//
//  Created by Vladislav Panev on 02.10.2024.
//

import Foundation

public enum LoadFeedResult<Error> {
    case success([FeedItem])
    case failure(Error)
}

extension LoadFeedResult: Equatable where Error: Equatable { }

public protocol FeedLoader {
    associatedtype Error
    func load(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
