//
//  File.swift
//  OnlineFeed
//
//  Created by Vladislav Panev on 02.10.2024.
//

import Foundation

public struct FeedItem: Codable, Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
