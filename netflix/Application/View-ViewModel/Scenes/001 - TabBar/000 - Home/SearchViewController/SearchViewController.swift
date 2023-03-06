//
//  SearchViewController.swift
//  netflix
//
//  Created by Zach Bazov on 16/12/2022.
//

import UIKit

// MARK: - ControllerProtocol Type

private protocol ControllerInput {
    func updateSearchQuery(_ query: String)
}

private protocol ControllerOutput {
    var collectionView: UICollectionView { get }
    var dataSource: SearchCollectionViewDataSource! { get }
    var searchController: UISearchController { get }
    var textFieldIndicatorView: TextFieldActivityIndicatorView? { get }
    
    func updateItems()
    func removeDataSource()
    func present()
    func backButtonDidTap()
}

private typealias ControllerProtocol = ControllerInput & ControllerOutput

// MARK: - SearchViewController Type

final class SearchViewController: Controller<SearchViewModel> {
    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var searchBarContainer: UIView!
    @IBOutlet private weak var contentContainer: UIView!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private(set) weak var searchBar: UISearchBar!
    
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate(set) var dataSource: SearchCollectionViewDataSource!
    fileprivate var searchController = UISearchController(searchResultsController: nil)
    fileprivate(set) lazy var textFieldIndicatorView: TextFieldActivityIndicatorView? = createTextFieldIndicatorView()
    
    deinit {
        viewDidUnbindObservers()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidDeploySubviews()
        viewDidTargetSubviews()
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
    
    override func viewDidTargetSubviews() {
        backButton.addTarget(self, action: #selector(backButtonDidTap), for: .touchUpInside)
    }
    
    override func viewDidBindObservers() {
        viewModel?.items.observe(on: self) { [weak self] _ in self?.updateItems() }
        viewModel?.query.observe(on: self) { [weak self] in self?.updateSearchQuery($0) }
    }
    
    override func viewDidUnbindObservers() {
        guard let viewModel = viewModel else { return }
        viewModel.items.remove(observer: self)
        viewModel.query.remove(observer: self)
        printIfDebug(.success, "Removed `SearchViewModel` observers.")
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
    
    fileprivate func updateSearchQuery(_ query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }
    
    fileprivate func removeDataSource() {
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.reloadData()
        collectionView.contentSize = .zero
        
        viewModel?.items.value = []
        
        AsyncImageService.shared.cache.removeAllObjects()
    }
    
    @objc
    fileprivate func backButtonDidTap() {
        let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first! as! HomeViewController
        let searchViewController = homeViewController.viewModel.coordinator!.search!.viewControllers.first! as! SearchViewController
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                homeViewController.viewModel.coordinator!.search.view.transform = CGAffineTransform(translationX: homeViewController.viewModel.coordinator!.search.view.bounds.width, y: .zero)
                homeViewController.viewModel.coordinator!.search.view.alpha = .zero
            },
            completion: { _ in
                homeViewController.viewModel.coordinator!.search.remove()
                searchViewController.viewModel = nil
                searchViewController.dataSource = nil
                homeViewController.viewModel.coordinator!.search = nil
            }
        )
    }
    
    func present() {
        let homeViewController = Application.app.coordinator.tabCoordinator.home.viewControllers.first! as! HomeViewController
        let searchNavigationController = homeViewController.viewModel.coordinator!.search!
        
        searchNavigationController.view.alpha = .zero
        searchNavigationController.view.transform = CGAffineTransform(translationX: searchNavigationController.view.bounds.width, y: .zero)
        
        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: .curveEaseInOut,
            animations: {
                searchNavigationController.view.transform = .identity
                searchNavigationController.view.alpha = 1.0
            }
        )
    }
}

// MARK: - UISearchBarDelegate Implementation

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.isEmpty else { return }
        searchController.isActive = false
        viewModel?.didSearch(query: text)
        
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel?.didCancelSearch()
        
        viewModel?.set(media: viewModel?.topSearches ?? [])
        
        dataSource.headerView.titleLabel.text = "Searches"
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count == 0 {
            searchBarCancelButtonClicked(searchBar)
        }
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

// MARK: - UISearchResultsUpdating Implementation

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.searchTextField.text, !searchText.isEmpty {
            dataSource.headerView.titleLabel.text = searchText
            return
        } else {
            viewModel?.set(media: viewModel?.topSearches ?? [])
        }
    }
}

// MARK: - Private UI Implementation

extension SearchViewController {
    private func setupDataSource() {
        dataSource = SearchCollectionViewDataSource(with: viewModel)
    }
    
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchBar.delegate = self
        searchBar.frame = searchBarContainer.bounds
        searchBar.barStyle = .black
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]
        let attributedString = NSAttributedString(string: "Search", attributes: attributes)
        searchBar.searchTextField.attributedPlaceholder = attributedString
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 6.0, vertical: .zero)
        searchBar.searchTextField.backgroundColor = .hexColor("#2B2B2B")
        searchBar.searchTextField.superview?.backgroundColor = .black
        searchBar.searchTextField.keyboardAppearance = .dark
        searchBar.searchTextField.autocapitalizationType = .none
        
        definesPresentationContext = true
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.accessibilityIdentifier = "Search Field"
        }
    }
    
    private func createCollectionView() -> UICollectionView {
        let layout = CollectionViewLayout(layout: .search, scrollDirection: .vertical)
        let collectionView = UICollectionView(frame: contentContainer.bounds, collectionViewLayout: layout)
        collectionView.register(CollectionViewHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CollectionViewHeaderView.reuseIdentifier)
        collectionView.register(SearchCollectionViewCell.nib,
                                forCellWithReuseIdentifier: SearchCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = .black
        contentContainer.addSubview(collectionView)
        collectionView.constraintToSuperview(contentContainer)
        return collectionView
    }
    
    private func createTextFieldIndicatorView() -> TextFieldActivityIndicatorView? {
        guard let searchBar = searchBar else { return nil }
        return TextFieldActivityIndicatorView(textField: searchBar.searchTextField)
    }
}
