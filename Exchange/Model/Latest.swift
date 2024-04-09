//
//  Latest.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import RealmSwift

final class Latest: Object, Codable {
    @Persisted var rates: Map<String, Double>
}
