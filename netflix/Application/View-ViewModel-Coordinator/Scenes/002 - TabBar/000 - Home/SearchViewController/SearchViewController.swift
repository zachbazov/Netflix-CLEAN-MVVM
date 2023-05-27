//
//  SearchViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import UIKit

// MARK: - ControllerProtocol Type

private protocol ControllerProtocol {
    var collectionView: UICollectionView { get }
    var dataSource: SearchCollectionViewDataSource? { get }
    var searchController: UISearchController { get }
    var textFieldIndicatorView: TextFieldActivityIndicatorView? { get }
    
    func backButtonDidTap()
    func updateSearchBarQuery(_ query: String)
}

// MARK: - SearchViewController Type

final class SearchViewController: UIViewController, Controller {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var barContainer: UIView!
    @IBOutlet private weak var searchBarContainer: UIView!
    @IBOutlet private weak var contentContainer: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    
    var viewModel: SearchViewModel!
    
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate(set) lazy var dataSource: SearchCollectionViewDataSource? = createDataSource()
    fileprivate var searchController = UISearchController(searchResultsController: nil)
    fileprivate(set) lazy var textFieldIndicatorView: TextFieldActivityIndicatorView? = createTextFieldIndicatorView()
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewWillLoadBehaviors()
        viewHierarchyWillConfigure()
        viewWillConfigure()
        viewWillTargetSubviews()
        viewWillBindObservers()
    }
    
    func viewHierarchyWillConfigure() {
        collectionView
            .addToHierarchy(on: contentContainer)
            .constraintToSuperview(contentContainer)
    }
    
    func viewWillConfigure() {
        configureSearchController()
        configureSearchBar()
        configureSearchBarTextField()
    }
    
    func viewWillTargetSubviews() {
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    }
    
    func viewWillBindObservers() {
        viewModel?.items.observe(on: self) { [weak self] in
            guard !$0.isEmpty else { return }
            
            self?.updateDataSource()
        }
        
        viewModel?.query.observe(on: self) { [weak self] in
            self?.updateSearchBarQuery($0)
        }
    }
    
    func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.items.remove(observer: self)
        viewModel.query.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchController.isActive = false
    }
    
    func viewWillDeallocate() {
        viewWillUnbindObservers()
        
        searchBar.searchTextField.resignFirstResponder()
        
        collectionView.removeFromSuperview()
        
        textFieldIndicatorView = nil
        dataSource = nil
        viewModel = nil
        
        removeFromParent()
    }
}

// MARK: - ControllerProtocol Implementation

extension SearchViewController: ControllerProtocol {
    @objc
    fileprivate func backButtonDidTap() {
        viewWillAnimateDisappearance { [weak self] in
            guard let self = self else { return }
            
            self.viewWillDeallocate()
        }
    }
    
    fileprivate func updateSearchBarQuery(_ query: String) {
        searchController.searchBar.text = query
    }
}

// MARK: - UISearchBarDelegate Implementation

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text,
              !text.isEmpty
        else { return }
        
        viewModel?.willSearch(for: text)
        
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel?.willCancelSearch()
        viewModel?.itemsWillChange(mapping: viewModel?.topSearches ?? [])
        
        dataSource?.headerView?.titleLabel.text = "Top Searches"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count == .zero else { return }
        
        searchBarCancelButtonClicked(searchBar)
    }
}

// MARK: - UISearchResultsUpdating Implementation

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.searchTextField.text, !searchText.isEmpty else {
            viewModel?.itemsWillChange(mapping: viewModel?.topSearches ?? [])
            
            return
        }
        
        dataSource?.headerView?.titleLabel.text = "Results for '\(searchText)'"
    }
}

// MARK: - Private Presentation Implementation

extension SearchViewController {
    private func createDataSource() -> SearchCollectionViewDataSource {
        return SearchCollectionViewDataSource(with: viewModel)
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .search, scrollDirection: .vertical)
        let collectionView = UICollectionView(frame: contentContainer.bounds, collectionViewLayout: layout)
        
        collectionView.register(LabeledCollectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: LabeledCollectionHeaderView.reuseIdentifier)
        collectionView.register(SearchCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentifier)
        
        collectionView.setBackgroundColor(.black)
        
        return collectionView
    }
    
    private func createTextFieldIndicatorView() -> TextFieldActivityIndicatorView? {
        guard let searchBar = searchBar else { return nil }
        
        return TextFieldActivityIndicatorView(textField: searchBar.searchTextField)
    }
    
    private func updateDataSource() {
        guard let dataSource = dataSource else { return }
        
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
    
    private func configureSearchController() {
        definesPresentationContext = true
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = true
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    private func configureSearchBar() {
        searchBar.delegate = self
        searchBar.frame = searchBarContainer.bounds
        searchBar.barStyle = .black
    }
    
    private func configureSearchBarTextField() {
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let attributedString = NSAttributedString(string: "Search...", attributes: attributes)
        
        searchBar.searchTextField.attributedPlaceholder = attributedString
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 6.0, vertical: .zero)
        searchBar.searchTextField.setBackgroundColor(.hexColor("#2B2B2B"))
        searchBar.searchTextField.superview?.setBackgroundColor(.black)
        searchBar.searchTextField.keyboardAppearance = .dark
        searchBar.searchTextField.autocapitalizationType = .none
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.accessibilityIdentifier = "Search Field"
        }
    }
}
