//
//  SearchViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import UIKit

// MARK: - ControllerProtocol Type

private protocol ControllerInput {
    func updateLoading(_ loading: SearchLoading?)
    func updateSearchQuery(_ query: String)
}

private protocol ControllerOutput {
    var collectionView: UICollectionView { get }
    var dataSource: SearchCollectionViewDataSource! { get }
    var searchController: UISearchController { get }
    
    func updateItems()
    func removeDataSource()
}

private typealias ControllerProtocol = ControllerInput & ControllerOutput

// MARK: - SearchViewController Type

final class SearchViewController: Controller<SearchViewModel> {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var searchBarContainer: UIView!
    @IBOutlet private var contentContainer: UIView!
    
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate var dataSource: SearchCollectionViewDataSource!
    fileprivate var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidDeploySubviews()
        viewDidBindObservers()
        viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }
    
    override func viewDidDeploySubviews() {
        setupSearchController()
        setupDataSource()
    }
    
    override func viewDidBindObservers() {
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
        viewModel.query.observe(on: self) { [weak self] in self?.updateSearchQuery($0) }
    }
    
    override func viewDidUnbindObservers() {
        printIfDebug(.success, "Removed `SearchViewModel` observers.")
        viewModel.items.remove(observer: self)
        viewModel.loading.remove(observer: self)
        viewModel.query.remove(observer: self)
    }
}

// MARK: - ControllerProtocol Implementation

extension SearchViewController: ControllerProtocol {
    fileprivate func updateItems() {
        guard let dataSource = dataSource else { return }
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
    
    fileprivate func updateLoading(_ loading: SearchLoading?) {
        contentContainer.isHidden(true)
        ActivityIndicatorView.viewDidHide()
        
        switch loading {
        case .fullscreen:
            ActivityIndicatorView.viewDidShow()
        case .nextPage:
            contentContainer.isHidden(false)
        case .none:
            contentContainer.isHidden(false)
        }
    }
    
    fileprivate func updateSearchQuery(_ query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }
    
    fileprivate func removeDataSource() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.reloadData()
        collectionView.contentSize = .zero
        
        viewModel.items.value = []
        
        AsyncImageService.shared.cache.removeAllObjects()
    }
}

// MARK: - UISearchBarDelegate Implementation

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        searchController.isActive = false
        viewModel?.didSearch(query: text)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel?.didCancelSearch()
    }
}

// MARK: - UISearchControllerDelegate Implementation

extension SearchViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        removeDataSource()
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        removeDataSource()
    }
}

// MARK: - Private UI Implementation

extension SearchViewController {
    private func setupDataSource() {
        dataSource = SearchCollectionViewDataSource(with: viewModel)
    }
    
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search..."
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.barStyle = .black
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = searchBarContainer.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth,  .flexibleHeight]
        searchController.searchBar.searchTextField.backgroundColor = .hexColor("#2B2B2B")
        searchController.searchBar.searchTextField.superview?.backgroundColor = .black
        searchController.searchBar.searchTextField.keyboardAppearance = .dark
        searchController.searchBar.searchTextField.autocapitalizationType = .none
        searchBarContainer.addSubview(searchController.searchBar)
        definesPresentationContext = true
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.accessibilityIdentifier = "Search Field"
        }
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .search, scrollDirection: .vertical)
        let collectionView = UICollectionView(frame: contentContainer.bounds, collectionViewLayout: layout)
        collectionView.register(SearchCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .black
        contentContainer.addSubview(collectionView)
        collectionView.constraintToSuperview(contentContainer)
        return collectionView
    }
}
