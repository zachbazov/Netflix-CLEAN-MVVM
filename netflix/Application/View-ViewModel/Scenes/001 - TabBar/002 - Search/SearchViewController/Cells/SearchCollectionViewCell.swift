//
//  SearchCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func viewDidConfigure(with viewModel: SearchCollectionViewCellViewModel)
}

private protocol ViewOutput {
    var representedIdentifier: NSString? { get }
    var hasGradient: Bool { get }
}

private typealias ViewProtocol = ViewInput & ViewOutput

// MARK: - SearchCollectionViewCell Type

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var gradientView: UIView!
    
    fileprivate var representedIdentifier: NSString?
    fileprivate var hasGradient = false
    /// Create a search collection view cell object.
    /// - Parameters:
    ///   - collectionView: Corresponding collection view.
    ///   - indexPath: The index path of the cell on the data source.
    ///   - viewModel: Coordinating view model.
    /// - Returns: A search collection view cell.
    static func create(on collectionView: UICollectionView,
                       for indexPath: IndexPath,
                       with viewModel: SearchViewModel) -> SearchCollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier,
            for: indexPath) as? SearchCollectionViewCell else {
            fatalError()
        }
        let media = viewModel.items.value[indexPath.row].media!
        let cellViewModel = SearchCollectionViewCellViewModel(media: media)
        view.representedIdentifier = cellViewModel.slug as NSString
        view.viewDidDeploySubviews()
        view.viewDidConfigure()
        view.viewDidConfigure(with: cellViewModel)
        return view
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        logoImageView.image = nil
    }
}

// MARK: - ViewLifecycleBehavior Implementation

extension SearchCollectionViewCell: ViewLifecycleBehavior {
    func viewDidDeploySubviews() {
        setupGradients()
    }
    
    func viewDidConfigure() {
        posterImageView.layer.cornerRadius = 10.0
    }
}

// MARK: - ViewProtocol Implementation

extension SearchCollectionViewCell: ViewProtocol {
    fileprivate func viewDidConfigure(with viewModel: SearchCollectionViewCellViewModel) {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        AsyncImageService.shared.load(
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                mainQueueDispatch { self?.posterImageView.image = image }
            }
        
        AsyncImageService.shared.load(
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                mainQueueDispatch { self?.logoImageView.image = image }
            }
    }
}

// MARK: - Private UI Implementation

extension SearchCollectionViewCell {
    private func setupGradients() {
        if !hasGradient {
            gradientView.addGradientLayer(
                colors: [.black.withAlphaComponent(1.0),
                         .black.withAlphaComponent(0.5),
                         .clear],
                locations: [0.2, 0.6, 1.0],
                points: [CGPoint(x: 1.0, y: 0.5), CGPoint(x: 0.0, y: 0.5)])
            
            hasGradient = true
        }
    }
}
