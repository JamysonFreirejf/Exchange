//
//  CacheRepositoryTests.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 17/01/24.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Exchange

struct MockItem: Codable, Cacheable {
    let title: String
    var lastUpdated: Date {
        Date(timeIntervalSince1970: 1)
    }
}

final class CacheRepositoryTests: XCTestCase {
    private var localRepository: MockLocalRepository!
    private var remoteRepository: MockRemoteRepository!
    private var cachedRepository: ExchangeRepository!
    private var dateProvider: DateProviderType!
    private var cacheHelper: MockCacheHelper!
    private var diposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        localRepository = MockLocalRepository()
        remoteRepository = MockRemoteRepository()
        dateProvider = MockDateProvider()
        cacheHelper = MockCacheHelper()
        cachedRepository = CacheRepository(localRepository: localRepository,
                                           remoteRepository: remoteRepository,
                                           dateProvider: MockDateProvider(),
                                           cacheHelper: cacheHelper)
        diposeBag = DisposeBag()
    }
    
    func testLocalCache() {
        let expectation = expectation(description: "Should emit local data")
        
        cacheHelper.expired = false
        let fetch: Observable<MockItem> = cachedRepository.fetch()
        fetch
            .map { $0.title }
            .subscribe(onNext: { value in
                XCTAssertEqual(value, "Local Data")
                expectation.fulfill()
            })
            .disposed(by: diposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testRemoteCache() {
        let expectation = expectation(description: "Should emit remote data")
        
        cacheHelper.expired = true
        let fetch: Observable<MockItem> = cachedRepository.fetch()
        fetch
            .map { $0.title }
            .subscribe(onNext: { value in
                XCTAssertEqual(value, "Remote Data")
                expectation.fulfill()
            })
            .disposed(by: diposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testFetchError() {
        let expectation = expectation(description: "Should emit remote data if there is an error for cached data")
        
        cacheHelper.expired = false
        localRepository.shouldForceError = true
        let fetch: Observable<MockItem> = cachedRepository.fetch()
        fetch
            .map { $0.title }
            .subscribe(onNext: { value in
                XCTAssertEqual(value, "Remote Data")
                expectation.fulfill()
            })
            .disposed(by: diposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
}
