//
//  URLSessionHTTPClientTests.swift
//  OnlineFeedTests
//
//  Created by Vladislav Panev on 04.10.2024.
//

import XCTest
import OnlineFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_shouldRequestWithGivenURL() {
        let url = makeAnyURL()

        let exp = expectation(description: "expect to get result")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }

        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_whenRequestCompletesWithErrorShouldCompleteWithError() {
        let error = NSError(domain: "test error", code: 1)
        getErrorResult(error: error)
    }

    func test_getFromURL_shouldFailOnAllInvalidRepresentations() {
        let anyURLResponse = URLResponse(url: makeAnyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyHTTPURLResponse = HTTPURLResponse(url: makeAnyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        let anyError = NSError(domain: "any error", code: 1)

        getErrorResult()
        getErrorResult(data: nil, response: anyURLResponse, error: nil)
        getErrorResult(data: makeAnyData(), response: nil, error: nil)
        getErrorResult(data: makeAnyData(), response: nil, error: anyError)
        getErrorResult(data: makeAnyData(), response: anyURLResponse, error: anyError)
        getErrorResult(data: nil, response: anyURLResponse, error: anyError)
        getErrorResult(data: makeAnyData(), response: anyHTTPURLResponse, error: anyError)
        getErrorResult(data: nil, response: anyHTTPURLResponse, error: anyError)
        getErrorResult(data: makeAnyData(), response: anyURLResponse, error: nil)
    }
    
    func test_getFromURL_whenValidRequestResponseShouldSuccess() {
        
        let response = HTTPURLResponse(url: makeAnyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)
        let exp = expectation(description: "expect to get result")
        getResult(data: makeAnyData(), response: response) { result in
            switch result {
            case .success:
                break
            default:
                XCTFail("Expected to success, but got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_whenHaveResponseAndRequestDataNillShouldSuccess() {
        let response = HTTPURLResponse(url: makeAnyURL(), statusCode: 0, httpVersion: nil, headerFields: nil)
        let exp = expectation(description: "expect to get result")
        getResult(response: response) { result in
            switch result {
            case .success:
                break
            default:
                XCTFail("Expected to success, but got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeAnyURL() -> URL {
        URL(string: "https://a-url.com")!
    }
    
    private func makeAnyData() -> Data {
        Data("any data".utf8)
    }
    
    private func makeSUT() -> HTTPClient {
        let sut = URLSessionHTTPClient()
        
        checkMemoryLeak(sut)
        
        return sut
    }
    
    private func getErrorResult(
        url: URL? = URL(string: "https://a-url.com")!,
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "expect to get result")

        getResult(
            url: url,
            data: data,
            response: response,
            error: error
        ) { result in
            switch result {
            case let .failure(recievedError):
                if let error = error {
                    XCTAssertEqual(
                        (recievedError as NSError).domain, (error as NSError).domain,
                        file: file,
                        line: line
                    )
                    XCTAssertEqual(
                        (recievedError as NSError).code, (error as NSError).code,
                        file: file,
                        line: line
                    )
                }
            default:
                XCTFail("Expected to get error but got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }
    
    private func getResult(
        url: URL? = URL(string: "https://a-url.com")!,
        data: Data? = nil,
        response: URLResponse? = nil,
        error: Error? = nil,
        completion: @escaping (HTTPClientResult) -> Void
    ) {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        makeSUT().get(from: url!) { result in
            completion(result)
        }
    }
    
    private final class URLProtocolStub: URLProtocol {
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }

        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?

        static func startInterceptingRequest() {
            URLProtocol.registerClass(self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(self)
            stub = nil
            requestObserver = nil
        }
        
        static func stub(
            data: Data? = nil,
            response: URLResponse? = nil,
            error: Error? = nil
        ) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequest(_ observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
