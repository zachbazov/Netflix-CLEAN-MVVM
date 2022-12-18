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
    
    var viewModel: SearchViewModel?
    
    private lazy var collectionView: UICollectionView = {
        let layout = CollectionViewLayout(layout: .standard, scrollDirection: .horizontal)
        let collectionView = UICollectionView(frame: contentContainer.bounds, collectionViewLayout: layout)
        collectionView.register(MediaListItemCell.nib, forCellWithReuseIdentifier: MediaListItemCell.reuseIdentifier)
        contentContainer.addSubview(collectionView)
        collectionView.constraintToSuperview(contentContainer)
        collectionView.backgroundColor = .gray
        return collectionView
    }()
    
    private var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        bind(to: viewModel!)
        viewModel?.viewDidLoad()
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
        title = "Search"
        setupSearchController()
        viewModel?.viewDidLoad()
        setup()
    }
    
    private func setup() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    private func bind(to viewModel: SearchViewModel) {
        viewModel.items.observe(on: self) { [weak self] _ in
            self?.updateItems()
        }
        viewModel.loading.observe(on: self) { [weak self] in
            self?.updateLoading($0)
        }
        viewModel.query.observe(on: self) { [weak self] in
            self?.updateSearchQuery($0)
        }
    }
    
    private func updateItems() {
        print("updatingitems", viewModel?.items.value.count)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.reloadData()
    }
    
    private func updateLoading(_ loading: SVMLoading?) {
//        contentContainer.isHidden(true)
        LoadingView.hide()
        
        switch loading {
        case .fullscreen:
            LoadingView.show()
        case .nextPage:
            contentContainer.isHidden(false)
        case .none:
//            contentContainer.isHidden = viewModel!.isEmpty
            break
        }
        
        
        ///
    }
    
    private func updateSearchQuery(_ query: String) {
        searchController.isActive = false
        searchController.searchBar.text = query
    }
}
extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel!.items.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaListItemCell.reuseIdentifier, for: indexPath) as? MediaListItemCell else {
            fatalError("as")
        }
        print("cell", cell)
        cell.fill(with: viewModel!.items.value[indexPath.row])
        
//        if indexPath.row == viewModel!.items.value.count - 1 {
//            viewModel?.didLoadNextPage()
//        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("indexPath", indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 414.0, height: 64.0)
    }
}

extension SearchViewController {
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

public class LoadingView {
    internal static var spinner: UIActivityIndicatorView?

    public static func show() {
        DispatchQueue.main.async {
            NotificationCenter.default.addObserver(self, selector: #selector(update), name: UIDevice.orientationDidChangeNotification, object: nil)
            if spinner == nil, let window = Application.current.rootCoordinator.window {
                let frame = UIScreen.main.bounds
                let spinner = UIActivityIndicatorView(frame: frame)
                spinner.backgroundColor = UIColor.black.withAlphaComponent(0.2)
                spinner.style = UIActivityIndicatorView.Style.large
                window.addSubview(spinner)

                spinner.startAnimating()
                self.spinner = spinner
            }
        }
    }

    public static func hide() {
        DispatchQueue.main.async {
            guard let spinner = spinner else { return }
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            self.spinner = nil
        }
    }

    @objc public static func update() {
        DispatchQueue.main.async {
            if spinner != nil {
                hide()
                show()
            }
        }
    }
}
