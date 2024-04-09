//
//  StubsDecoder.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import Foundation

@testable import Exchange

final class StubsDecoder {
    func decode<T: Codable>(_ t: T.Type, resource: String) -> T? {
        let bundle = Bundle(for: type(of: self))
        return bundle.decode(t, resource: resource)
    }
}
