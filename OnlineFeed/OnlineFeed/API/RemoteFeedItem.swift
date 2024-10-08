//
//  RemoteFeedItem.swift
//  OnlineFeed
//
//  Created by Vladislav Panev on 08.10.2024.
//

import Foundation

struct RemoteFeedItem: Codable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
