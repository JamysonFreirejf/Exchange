//
//  ExchangeRates.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import RealmSwift

protocol Cacheable {
    var lastUpdated: Date { get }
}

final class ExchangeRates: Object, Codable, Cacheable {
    @Persisted(primaryKey: true) var id: ObjectId = .init()
    @Persisted var latest: Latest?
    @Persisted var currencies: Map<String, String>
    @Persisted var lastUpdated: Date
    
    convenience init(latest: Latest, currencies: Map<String, String>, lastUpdated: Date) {
        self.init()
        self.latest = latest
        self.currencies = currencies
        self.lastUpdated = lastUpdated
    }
    
    convenience init(latest: Latest, currencies: Map<String, String>) {
        self.init()
        self.latest = latest
        self.currencies = currencies
    }
}
