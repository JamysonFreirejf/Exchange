//
//  CurrencyViewModelTests.swift
//  ExchangeTests
//
//  Created by Jamyson Freire Braga on 18/01/24.
//

import XCTest
import RxTest
import RxSwift
import RxCocoa

@testable import Exchange

final class CurrencyViewModelTests: XCTestCase {
    private var viewModel: CurrencyViewModelType!
    private var disposeBag: DisposeBag!
    private var scheduler: TestScheduler!
    
    override func setUp() {
        super.setUp()
        viewModel = CurrencyViewModel(currencies: [
            CurrencyItem(currency: "BRL", value: ""),
            CurrencyItem(currency: "USD", value: ""),
            CurrencyItem(currency: "EUR", value: "")
        ])
        disposeBag = DisposeBag()
        scheduler = TestScheduler(initialClock: 0)
    }
    
    func testSelectCurrency() {
        let expectListNotEmpty = expectation(description: "Expect list to be filled")
        let selectedCurrency = scheduler.createObserver(String.self)
        
        viewModel.selectedCurrency
            .map { $0?.currency ?? "" }
            .asObservable()
            .bind(to: selectedCurrency)
            .disposed(by: disposeBag)
        
        viewModel.currencies
            .drive(onNext: { value in
                XCTAssertFalse(value.isEmpty)
                expectListNotEmpty.fulfill()
            })
            .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(10, [CurrencyItem(currency: "BRL", value: "")]),
            .next(20, [CurrencyItem(currency: "USD", value: ""),
                       CurrencyItem(currency: "EUR", value: "")]),
            .next(30, [CurrencyItem(currency: "BTC", value: "")]),
            .next(35, [CurrencyItem(currency: "ALL", value: "")]),
            .next(45, [CurrencyItem(currency: "BRL", value: "")]),
        ])
        .asObservable()
        .bind(to: viewModel.bindSelectedCurrency)
        .disposed(by: disposeBag)
        
        scheduler.createColdObservable([
            .next(15, ()),
            .next(20, ()),
            .next(30, ()),
            .next(40, ()),
            .next(45, ()),
        ])
        .asObservable()
        .bind(to: viewModel.bindConfirm)
        .disposed(by: disposeBag)
        
        scheduler.start()
        
        XCTAssertEqual(selectedCurrency.events, [
            .next(15, "BRL"),
            .next(20, "EUR"),
            .next(30, "BTC"),
            .next(40, "ALL"),
            .next(45, "BRL"),
        ])
        
        wait(for: [expectListNotEmpty], timeout: 1)
    }
}
