//
//  LocalRepositoryTests.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import XCTest
import RxSwift
import RxCocoa
import RealmSwift

@testable import Exchange

final class LocalRepositoryTests: XCTestCase {
    private var repository: LocalRepository!
    private var realm: Realm!
    private var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        let config = Realm.Configuration(inMemoryIdentifier: name)
        realm = try! Realm(configuration: config)
        repository = LocalRepository(realm: realm)
        disposeBag = DisposeBag()
    }
    
    func testUpdate() {
        XCTAssert(realm.objects(ExchangeRates.self).isEmpty)
        
        repository.update(ExchangeRates())
        XCTAssertEqual(realm.objects(ExchangeRates.self).count, 1)

        for _ in  1...5 {
            repository.update(ExchangeRates())
        }
        
        XCTAssertEqual(realm.objects(ExchangeRates.self).count, 1)
    }
    
    func testFetch() {
        let expectError = expectation(description: "Expect fetch to return error for not having data")
        let expectData = expectation(description: "Expect fetch to return data after update")
        
        fetchRates()
            .subscribe(onError: { _ in
                expectError.fulfill()
            })
            .disposed(by: disposeBag)
        
        repository.update(ExchangeRates())
        
        fetchRates()
            .subscribe(onNext: { _ in
                expectData.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectError,
                   expectData], timeout: 1)
    }
}

private extension LocalRepositoryTests {
    func fetchRates() -> Observable<ExchangeRates> {
        repository.fetch()
    }
}
