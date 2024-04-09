//
//  DateHelper.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 17/01/24.
//

import Foundation

struct DateHelper {
    func createDate(from dateString: String, format: String = "yyyy-MM-dd HH:mm:ss") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: dateString) ?? Date()
    }
}
