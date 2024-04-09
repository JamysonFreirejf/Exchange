//
//  CacheHelperTests.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 17/01/24.
//

import XCTest

@testable import Exchange

final class CacheHelperTests: XCTestCase {
    private var cacheHelper: CacheHelperType!
    private var dateHelper: DateHelper!
    
    override func setUp() {
        super.setUp()
        cacheHelper = CacheHelper()
        dateHelper = DateHelper()
    }
    
    func testCacheStrategy() {
        XCTAssertTrue(cacheHelper.isCacheExpired(lastUpdated: dateHelper.createDate(from: "2024-01-15 12:30:00"),
                                                 currentDate: dateHelper.createDate(from: "2024-01-15 13:00:00"),
                                                 refreshTimeInMinutes: 30))
        XCTAssertTrue(cacheHelper.isCacheExpired(lastUpdated: dateHelper.createDate(from: "2024-01-15 12:30:00"),
                                                 currentDate: dateHelper.createDate(from: "2024-01-15 13:00:00"),
                                                 refreshTimeInMinutes: 5))
        XCTAssertFalse(cacheHelper.isCacheExpired(lastUpdated: dateHelper.createDate(from: "2024-01-15 12:30:00"),
                                                  currentDate: dateHelper.createDate(from: "2024-01-15 12:31:00"),
                                                 refreshTimeInMinutes: 3))
        XCTAssertFalse(cacheHelper.isCacheExpired(lastUpdated: dateHelper.createDate(from: "2024-01-15 12:30:00"),
                                                  currentDate: dateHelper.createDate(from: "2024-01-15 12:45:00"),
                                                 refreshTimeInMinutes: 40))
        XCTAssertTrue(cacheHelper.isCacheExpired(lastUpdated: dateHelper.createDate(from: "2024-01-15 12:30:00"),
                                                  currentDate: .distantFuture,
                                                 refreshTimeInMinutes: 40))
    }
}
