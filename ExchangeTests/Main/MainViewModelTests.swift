//
//  MainViewModelTests.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 17/01/24.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa
import RealmSwift

@testable import Exchange

final class MainViewModelTests: XCTestCase {
    
    private var viewModel: MainViewModelType!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    private var dateHelper: DateHelper!
    private var repository: MockRepository!
    
    override func setUp() {
        super.setUp()
        repository = MockRepository(lastUpdated: DateHelper().createDate(from: "2024-01-15 12:30:00"))
        viewModel = MainViewModel(repository: repository,
                                  dateProvider: MockDateProvider())
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
        dateHelper = DateHelper()
    }
    
    func testResults() {
        let results = scheduler.createObserver([String].self)
        
        filteredResults(currency: "BRL")
            .bind(to: results)
            .disposed(by: disposeBag)
        
        viewModel.bindFetch()
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(10, "1"),
            .next(20, "10"),
            .next(30, "100"),
            .next(40, "100.52")
        ])
        .asObservable()
        .bind(to: viewModel.bindInput)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(results.events, [
            .next(10, ["BRL - 4.9263"]),
            .next(20, ["BRL - 49.263000000000005"]),
            .next(30, ["BRL - 492.63000000000005"]),
            .next(40, ["BRL - 495.19167600000003"])
        ])
    }
    
    func testResultsWithDifferentSelectedCurrency() {
        let results = scheduler.createObserver([String].self)
        let selectedCurrency = scheduler.createObserver(String.self)
        let showCurrenciesScreen = scheduler.createObserver(Bool.self)
        
        filteredResults(currency: "EUR")
            .bind(to: results)
            .disposed(by: disposeBag)
        
        viewModel.showCurrenciesScreen
            .asObservable()
            .map { !$0.isEmpty }
            .bind(to: showCurrenciesScreen)
            .disposed(by: disposeBag)
        
        viewModel.selectedCurrency
            .asObservable()
            .bind(to: selectedCurrency)
            .disposed(by: disposeBag)
        
        viewModel.bindFetch()
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(10, "1"),
            .next(20, "10"),
            .next(30, "100"),
            .next(40, "100.52")
        ])
        .asObservable()
        .bind(to: viewModel.bindInput)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(15, ()),
            .next(25, ()),
            .next(35, ()),
        ])
        .asObservable()
        .bind(to: viewModel.bindShowCurrencies)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(15, CurrencyItem(currency: "BRL", value: "")),
            .next(25, CurrencyItem(currency: "EUR", value: "")),
            .next(35, CurrencyItem(currency: "BTC", value: "")),
        ])
        .asObservable()
        .bind(to: viewModel.bindSelectedCurrency)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(selectedCurrency.events, [
            .next(0, "USD"),
            .next(15, "BRL"),
            .next(25, "EUR"),
            .next(35, "BTC")
        ])
        
        XCTAssertEqual(results.events, [
            .next(10, ["EUR - 0.920548"]),
            .next(15, ["EUR - 0.18686397499137283"]),
            .next(20, ["EUR - 1.8686397499137284"]),
            .next(25, ["EUR - 10.0"]),
            .next(30, ["EUR - 100.0"]),
            .next(35, []),
            .next(40, [])
        ])
        
        XCTAssertEqual(showCurrenciesScreen.events, [
            .next(15, true),
            .next(25, true),
            .next(35, true)
        ])
    }
    
    func testLastUpdated() {
        let expectation = expectation(description: "Check for last updated string")
        
        viewModel.bindFetch()
            .disposed(by: disposeBag)
        
        viewModel.lastUpdated
             .map { $0 ?? "" }
             .filter { !$0.isEmpty }
             .drive(onNext: { value in
                 XCTAssertEqual(value, "Last Updated: 2024-01-15 15:30:00")
                 expectation.fulfill()
             })
             .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testLoading() {
        let expectationShowLoading = expectation(description: "Expect loading to show")
        let expectationHideLoading = expectation(description: "Expect loading to hide")
        expectationShowLoading.assertForOverFulfill = false
        expectationHideLoading.assertForOverFulfill = false
        
        viewModel.showLoading
            .drive(onNext: { _ in
                expectationShowLoading.fulfill()
            })
            .disposed(by: disposeBag)
        viewModel.hideLoading
            .drive(onNext: { _ in
                expectationHideLoading.fulfill()
            })
            .disposed(by: disposeBag)
        
        viewModel.bindFetch()
            .disposed(by: disposeBag)
        
        let result = XCTWaiter.wait(for: [expectationShowLoading,
                                          expectationHideLoading], enforceOrder: true)
        XCTAssertEqual(result, .completed)
    }
    
    func testError() {
        let expectation = expectation(description: "Expect error description to emit")
        
        repository.forceError = true
        
        viewModel.errorDescription
            .drive(onNext: { error in
                XCTAssertFalse(error.isEmpty)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)
        
        viewModel.bindFetch()
            .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testNoDataLayoutState() {
        let isNoDataLayoutHidden = scheduler.createObserver(Bool.self)
        
        viewModel.isNoDataLayoutHidden
            .asObservable()
            .bind(to: isNoDataLayoutHidden)
            .disposed(by: disposeBag)
        
        repository.forceError = true
        
        viewModel.bindFetch()
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(10, "1"),
            .next(20, ""),
            .next(30, nil)
        ])
        .asObservable()
        .bind(to: viewModel.bindInput)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(isNoDataLayoutHidden.events, [
            .next(0, true),
            .next(10, false),
            .next(20, true)
        ])
    }
}

private extension MainViewModelTests {
    func filteredResults(currency: String) -> Observable<[String]> {
        viewModel.results
            .map { result in
                result.filter { $0.currency == currency }
            }
            .map { result in
                result.map { "\($0.currency) - \($0.value)" }
            }
            .asObservable()
    }
}
