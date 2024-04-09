//
//  MockCacheHelper.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import Foundation
@testable import Exchange

final class MockCacheHelper: CacheHelperType {
    var expired = false
    
    func isCacheExpired(lastUpdated: Date, currentDate: Date, refreshTimeInMinutes: Int) -> Bool {
        expired
    }
}
