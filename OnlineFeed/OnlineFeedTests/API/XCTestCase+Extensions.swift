//
//  XCTestCase+Extensions.swift
//  OnlineFeedTests
//
//  Created by Vladislav Panev on 04.10.2024.
//

import XCTest

extension XCTestCase {
    func checkMemoryLeak(
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
