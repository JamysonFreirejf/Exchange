//
//  CacheHelper.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 17/01/24.
//

import Foundation

protocol CacheHelperType {
    func isCacheExpired(lastUpdated: Date, currentDate: Date, refreshTimeInMinutes: Int) -> Bool
}

struct CacheHelper: CacheHelperType {
    func isCacheExpired(lastUpdated: Date, currentDate: Date, refreshTimeInMinutes: Int) -> Bool {
        if let dateMinutesAgo = Calendar.current.date(byAdding: .minute,
                                                      value: -refreshTimeInMinutes,
                                                      to: currentDate) {
            return lastUpdated <= dateMinutesAgo
        }
        return true
    }
}
