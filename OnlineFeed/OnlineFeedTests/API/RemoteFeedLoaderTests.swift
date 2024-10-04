//
//  RemoteFeedLoaderTests.swift
//  OnlineFeedTests
//
//  Created by Vladislav Panev on 02.10.2024.
//

import XCTest
import OnlineFeed

class RemoteFeedLoaderTests: XCTestCase {

    func test_init_shouldInitWithNilRequestURL() {
        // given
        let (_, client) = makeSUT()
        // then
        XCTAssertNil(client.requestURL)
    }

    func test_load_shouldSetRequestURL() {
        // given
        let expectedURL = URL(string: "https://a-expected-url.com")!

        let (sut, client) = makeSUT(url: expectedURL)
        // when
        sut.load { _ in }
        // then
        XCTAssertEqual(client.requestURL, expectedURL)
    }

    func test_load_shouldCallCorrect() {
        // given
        let expectedURL = URL(string: "https://a-expected-url.com")!

        let (sut, client) = makeSUT(url: expectedURL)
        // when
        sut.load { _ in }
        sut.load { _ in }
        // then
        XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
    }

    func test_load_shouldCompleteWithError() {
        executeLoad({
            $0.complete(with: .failure(NSError(domain: "Test", code: 0)))
        }, expectedResponse: [.failure(.connectivity)])
    }

    func test_load_when200HTTPStatusAndInvalidJSONDataShouldCompleteWithInvalidDataError() {
        executeLoad({
            $0.complete(with: 200, data: Data("invalid data".utf8))
        }, expectedResponse: [.failure(.invalidData)])
    }
    
    func test_load_when200HTTPStatusAndEmptyJSONShouldCompleteWithEmptyFeedItems() {
        executeLoad({
            $0.complete(with: 200, data: Data("{\"items\": []}".utf8))
        }, expectedResponse: [.success([])])
    }
    
    func test_load_whenNot200HTTPStatusAndEmptyJSONShouldCompleteWithInvalidDataError() {
        //when
        let statusCodes = [199, 201, 300, 400, 500]

        statusCodes.forEach { element in
            executeLoad({ client in
                client.complete(with: element, data: Data("{\"items\": []}".utf8))
            }, expectedResponse: [.failure(.invalidData)])
        }
    }

    func test_load_when200HTTPStatusAndVallidJSONShouldCompleteWithFeedItems() {
        executeLoad({
            let json = try! JSONSerialization.data(withJSONObject: TestData.itemsJSON)
            $0.complete(with: 200, data: json)
        }, expectedResponse: [.success([TestData.feedItem1, TestData.feedItem2])])
    }
    
    func test_load_whenDealocatedShouldNotComplete() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var responses: [RemoteFeedLoader.Response] = []
        sut!.load { responses.append($0)}
        
        sut = nil
        
        client.complete(with: 200, data: Data("{\"items\": []}".utf8))
        
        XCTAssertEqual(responses, [])
    }

    private func makeSUT(
        url: URL = URL(string: "https://a-url.com")!,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        checkMemoryLeak(sut, file: file, line: line)
        checkMemoryLeak(client, file: file, line: line)
        
        return (sut, client)
    }
    
    private func executeLoad(
        _ action: (HTTPClientSpy) -> Void,
        expectedResponse: [RemoteFeedLoader.Response]
    ) {
        let (sut, client) = makeSUT()
        var responses: [RemoteFeedLoader.Response] = []
        sut.load { responses.append($0)}
        
        action(client)
        
        // then
        XCTAssertEqual(responses, expectedResponse)
    }

    private class HTTPClientSpy: HTTPClient {
        var requestURL: URL? {
            messages.last?.url
        }

        var requestedURLs: [URL] {
            var urls: [URL] = []
            messages.forEach { urls.append($0.url) }
            return urls
        }

        var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []

        func get(from url: URL, _ completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: HTTPClientResult, at index: Int = 0) {
            messages[index].completion(error)
        }

        func complete(with statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: messages[index].url,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success(data, response))
        }
    }
}

private extension RemoteFeedLoaderTests {
    enum TestData {
        static let feedItem1 = FeedItem(
            id: UUID(),
            description: "desc",
            location: "loc",
            imageURL: URL(string: "https://a-url.com")!
        )
        
        static let feedItem2 = FeedItem(
            id: UUID(),
            description: nil,
            location: nil,
            imageURL: URL(string: "https://a-url.com")!
        )
        
        static let feedItem1JSON: [String: Any] = [
            "id": feedItem1.id.uuidString,
            "description": feedItem1.description!,
            "location": feedItem1.location!,
            "image": feedItem1.imageURL.absoluteString
        ]
        
        static let feedItem2JSON: [String: Any] = [
            "id": feedItem2.id.uuidString,
            "image": feedItem2.imageURL.absoluteString
        ]
        
        static let itemsJSON = [
            "items": [feedItem1JSON, feedItem2JSON]
        ]
    }
}
