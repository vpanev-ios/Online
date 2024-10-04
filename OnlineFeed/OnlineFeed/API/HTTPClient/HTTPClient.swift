//
//  HTTPClient.swift
//  OnlineFeed
//
//  Created by Vladislav Panev on 03.10.2024.
//

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void)
}
