//
//  MockDateProvider.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import Foundation

@testable import Exchange

struct MockDateProvider: DateProviderType {
    var currentDate: Date {
        DateHelper().createDate(from: "2024-01-15 12:30:00")
    }
    
    var timeZone: TimeZone {
        TimeZone(identifier: "UTC")!
    }
}
