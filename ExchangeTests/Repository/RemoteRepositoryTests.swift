//
//  RemoteRepositoryTests.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import XCTest
import RxSwift
import RxCocoa

@testable import Exchange

final class RemoteRepositoryTests: XCTestCase {
    private var apiClient: MockAPIClient!
    private var repository: RemoteRepository!
    private var disposeBag: DisposeBag!
    private var urlSession: MockURLSession!
    
    override func setUp() {
        super.setUp()
        apiClient = MockAPIClient()
        urlSession = MockURLSession()
        repository = RemoteRepository(apiClient: apiClient,
                                      urlSession: urlSession)
        disposeBag = DisposeBag()
    }
    
    func testSuccessfull() {
        let expectation = expectation(description: "Wait for fetch to succeed")
        
        let data: Observable<ExchangeRates> = repository.fetch()
        data
            .subscribe(onNext: { value in
                XCTAssertNotNil(value)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testError() {
        let expectation = expectation(description: "Wait for fetch to fail")
        
        urlSession.forceError = true
        let data: Observable<ExchangeRates> = repository.fetch()
        data
            .subscribe(onError: { error in
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
}
