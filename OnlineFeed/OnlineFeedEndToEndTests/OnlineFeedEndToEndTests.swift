//
//  OnlineFeedEndToEndTests.swift
//  OnlineFeedEndToEndTests
//
//  Created by Vladislav Panev on 04.10.2024.
//

import XCTest
import OnlineFeed

final class OnlineFeedEndToEndTests: XCTestCase {
    
    func test_endToEndTestServerGETFeedResult_matchesFixedTestAccountData() {
        switch makeResult() {
        case .success(let array):
            XCTAssertEqual(array.count, 8)

            XCTAssertEqual(array[0], TestData.makeFeedItem(at: 0))
            XCTAssertEqual(array[1], TestData.makeFeedItem(at: 1))
            XCTAssertEqual(array[2], TestData.makeFeedItem(at: 2))
            XCTAssertEqual(array[3], TestData.makeFeedItem(at: 3))
            XCTAssertEqual(array[4], TestData.makeFeedItem(at: 4))
            XCTAssertEqual(array[5], TestData.makeFeedItem(at: 5))
            XCTAssertEqual(array[6], TestData.makeFeedItem(at: 6))
            XCTAssertEqual(array[7], TestData.makeFeedItem(at: 7))
        case .failure(let error):
            XCTFail("Expected success, got \(error)")
        default:
            XCTFail("Expected success, got no result")
        }
    }
}

private extension OnlineFeedEndToEndTests {
    func makeResult() -> LoadFeedResult<RemoteFeedLoader.Error>? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: testServerURL, client: client)
        
        checkMemoryLeak(client)
        checkMemoryLeak(loader)
        
        let exp = expectation(description: "wait to load complete")
        
        var recievedResult: LoadFeedResult<RemoteFeedLoader.Error>?
        loader.load { result in
            recievedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 10.0)
        return recievedResult
    }

    enum TestData {
        static func makeFeedItem(at index: Int) -> FeedItem {
            FeedItem(
                id: makeUUID(at: index),
                description: [0, 2, 4, 5, 6, 7].contains(index) ? "Description \(index + 1)" : nil,
                location: [0, 1, 4, 5, 6, 7].contains(index) ? "Location \(index + 1)" : nil,
                imageURL: URL(string: "https://url-\(index + 1).com")!
            )
        }
        
        static func makeUUID(at index: Int) -> UUID {
            switch index {
            case 0:
                return UUID(uuidString: "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6")!
            case 1:
                return UUID(uuidString: "BA298A85-6275-48D3-8315-9C8F7C1CD109")!
            case 2:
                return UUID(uuidString: "5A0D45B3-8E26-4385-8C5D-213E160A5E3C")!
            case 3:
                return UUID(uuidString: "FF0ECFE2-2879-403F-8DBE-A83B4010B340")!
            case 4:
                return UUID(uuidString: "DC97EF5E-2CC9-4905-A8AD-3C351C311001")!
            case 5:
                return UUID(uuidString: "557D87F1-25D3-4D77-82E9-364B2ED9CB30")!
            case 6:
                return UUID(uuidString: "A83284EF-C2DF-415D-AB73-2A9B8B04950B")!
            case 7:
                return UUID(uuidString: "F79BD7F8-063F-46E2-8147-A67635C3BB01")!
            default:
                return UUID()
            }
        }
    }
}
