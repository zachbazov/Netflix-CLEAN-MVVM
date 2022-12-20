//
//  SearchViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import UIKit

final class SearchViewController: UIViewController {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var searchBarContainer: UIView!
    @IBOutlet private var contentContainer: UIView!
    
    var viewModel: SearchViewModel!
    
    private lazy var collectionView = createCollectionView()
    private var dataSource: SearchCollectionViewDataSource!
    private var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupObservers()
        viewModel.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchController.isActive = false
    }
    
    private func setupBehaviours() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
    
    private func setupSubviews() {
        setupSearchController()
        setupDataSource()
    }
    
    private func setupObservers() {
        viewModel.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel.loading.observe(on: self) { [weak self] in self?.updateLoading($0) }
        viewModel.query.observe(on: self) { [weak self] in self?.updateSearchQuery($0) }
    }
    
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

extension SearchViewController {
    private func updateItems() {
        guard let dataSource = dataSource else { return }
        collectionView.delegate = dataSource
        collectionView.dataSource = dataSource
        collectionView.reloadData()
    }
    
    private func updateLoading(_ loading: SearchLoading?) {
        contentContainer.isHidden(true)
        SpinnerView.hide()
        
        switch loading {
        case .fullscreen:
            SpinnerView.show()
        case .nextPage:
            contentContainer.isHidden(false)
        case .none:
            contentContainer.isHidden(false)
        }
    }
    
    private func updateSearchQuery(_ query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }
    
    private func removeDataSource() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.reloadData()
        collectionView.contentSize = .zero
        
        viewModel.items.value = []
        
        AsyncImageFetcher.shared.searchCache.removeAllObjects()
    }
}

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
