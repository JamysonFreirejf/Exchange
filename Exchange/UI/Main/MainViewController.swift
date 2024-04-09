//
//  MainViewController.swift
//  Exchange
//
//  Created by Jamyson Freire Braga on 16/01/24.
//

import UIKit
import RxSwift
import RxCocoa

final class MainViewController: UIViewController {
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var selectedCurrencyButton: UIButton!
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(UINib(nibName: String(describing: ResultViewCell.self), bundle: nil),
                                    forCellWithReuseIdentifier: String(describing: ResultViewCell.self))
            collectionView.delegate = self
        }
    }
    @IBOutlet private weak var lastUpdatedLabel: UILabel!
    @IBOutlet private weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private weak var noDataView: UIView!
    @IBOutlet private weak var tryAgainButton: UIButton!
    
    private let viewModel: MainViewModelType = MainViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpListeners()
        setUpBindings()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputTextField.becomeFirstResponder()
    }
}

private extension MainViewController {
    func setUpBindings() {
        viewModel.bindFetch()
            .disposed(by: disposeBag)
        viewModel.bindInput(observable: inputTextField.rx.text.asObservable())
            .disposed(by: disposeBag)
        viewModel.bindShowCurrencies(observable: selectedCurrencyButton.rx.tap.asObservable())
            .disposed(by: disposeBag)
        viewModel.isNoDataLayoutHidden
            .drive(noDataView.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    func setUpListeners() {
        viewModel.selectedCurrency
            .drive(selectedCurrencyButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        viewModel.lastUpdated
            .drive(lastUpdatedLabel.rx.text)
            .disposed(by: disposeBag)
        viewModel.results
            .drive(collectionView.rx.items(cellIdentifier: String(describing: ResultViewCell.self),
                                           cellType: ResultViewCell.self)) { _, resultItem, cell in
                cell.setUpView(resultItem: resultItem)
            }
            .disposed(by: disposeBag)
        viewModel.showCurrenciesScreen
            .drive(onNext: { [weak self] currencies in
                self?.showCurrenciesScreen(currencies: currencies)
            })
            .disposed(by: disposeBag)
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] _ in
                self?.inputTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        viewModel.showLoading
            .drive(onNext: { [weak self] _ in
                self?.showLoading()
            })
            .disposed(by: disposeBag)
        viewModel.hideLoading
            .drive(onNext: { [weak self] _ in
                self?.hideLoading()
            })
            .disposed(by: disposeBag)
        viewModel.errorDescription
            .drive(onNext: { [weak self] error in
                self?.showErrorDialog(error)
            })
            .disposed(by: disposeBag)
        tryAgainButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.viewModel.retryFetch()
            })
            .disposed(by: disposeBag)
    }
    
    func showLoading() {
        collectionView.isHidden = true
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
    }
    
    func hideLoading() {
        collectionView.isHidden = false
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    
    func showErrorDialog(_ error: String) {
        guard !error.isEmpty else { return }
        let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Retry", style: .default, handler: { [weak self] action in
            switch action.style {
            case .default:
                self?.viewModel.retryFetch()
            default:
                break
            }
        }))
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alertController, animated: true)
    }
    
    func showCurrenciesScreen(currencies: [CurrencyItem]) {
        let currencyViewController = CurrencyViewController(nibName: String(describing: CurrencyViewController.self), bundle: nil)
        currencyViewController.modalPresentationStyle = .overFullScreen
        let currencyViewModel = CurrencyViewModel(currencies: currencies)
        currencyViewController.viewModel = currencyViewModel
        
        viewModel.bindSelectedCurrency(observable: currencyViewModel.selectedCurrency.asObservable())
            .disposed(by: currencyViewController.disposeBag)
        
        present(currencyViewController, animated: true, completion: nil)
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width / 3, height: 100)
    }
}
