//
//  URLSessionHTTPClient.swift
//  OnlineFeed
//
//  Created by Vladislav Panev on 04.10.2024.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private struct UnvalidResponseError: Error { }
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func get(
        from url: URL,
        _ completion: @escaping (OnlineFeed.HTTPClientResult) -> Void
    ) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,
              let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnvalidResponseError()))
            }
        }.resume()
    }
}
