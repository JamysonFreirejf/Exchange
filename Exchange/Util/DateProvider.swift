//
//  DateProvider.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import Foundation

protocol DateProviderType {
    var currentDate: Date { get }
    var timeZone: TimeZone { get }
}

struct DateProvider: DateProviderType {
    var currentDate: Date {
        Date()
    }
    
    var timeZone: TimeZone {
        .current
    }
}
