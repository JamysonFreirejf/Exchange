//
//  Bundle+Decoder.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 19/01/24.
//

import Foundation

extension Bundle {
    func decode<T: Codable>(_ t: T.Type, resource: String) -> T? {
        guard let data = data(t.self, resource: resource),
              let response = try? JSONDecoder().decode(t.self, from: data) else {
            return nil
        }
        return response
    }
    
    func data<T: Codable>(_ t: T.Type, resource: String) -> Data? {
        guard let url = url(forResource: resource, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return data
    }
}
