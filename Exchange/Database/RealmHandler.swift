//
//  RealmHandler.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import RealmSwift

final class RealmHandler {
    let realm = try! Realm()
    
    static var shared: RealmHandler = RealmHandler()
}
