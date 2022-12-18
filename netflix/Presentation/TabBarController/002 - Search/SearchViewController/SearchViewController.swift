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
        title = viewModel?.title
        
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
        searchController.searchBar.barStyle = .default
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.frame = searchBarContainer.bounds
        searchController.searchBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        searchBarContainer.addSubview(searchController.searchBar)
        definesPresentationContext = true
        if #available(iOS 13.0, *) {
            searchController.searchBar.searchTextField.accessibilityIdentifier = "Search Field"
        }
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .search, scrollDirection: .vertical)
        let collectionView = UICollectionView(frame: contentContainer.bounds, collectionViewLayout: layout)
        collectionView.register(StandardCollectionViewCell.nib,
                                forCellWithReuseIdentifier: StandardCollectionViewCell.reuseIdentifier)
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
        ///
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        ///
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        ///
    }
}