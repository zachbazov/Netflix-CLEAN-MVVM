//
//  SearchCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 19/12/2022.
//

import UIKit

class SearchCollectionViewCell: UICollectionViewCell {
    @IBOutlet private var posterImageView: UIImageView!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var gradientView: UIView!
    
    private var representedIdentifier: NSString?
    private var appliedGradient = false
    
    static func create(on collectionView: UICollectionView,
                       for indexPath: IndexPath,
                       with viewModel: SearchViewModel) -> SearchCollectionViewCell {
        guard let view = collectionView.dequeueReusableCell(
            withReuseIdentifier: SearchCollectionViewCell.reuseIdentifier,
            for: indexPath) as? SearchCollectionViewCell else {
            fatalError()
        }
        let media = viewModel.items.value[indexPath.row].toMedia()
        let cellViewModel = SearchCollectionViewCellViewModel(media: media)
        view.representedIdentifier = cellViewModel.slug as NSString
        view.setupSubviews()
        view.viewDidConfigure(with: cellViewModel)
        return view
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        logoImageView.image = nil
    }
    
    private func setupSubviews() {
        setupGradientView()
        posterImageView.layer.cornerRadius = 10.0
    }
    
    private func viewDidConfigure(with viewModel: SearchCollectionViewCellViewModel) {
        guard representedIdentifier == viewModel.slug as NSString? else { return }
        
        AsyncImageFetcher.shared.load(
            in: .search,
            url: viewModel.posterImageURL,
            identifier: viewModel.posterImageIdentifier) { [weak self] image in
                asynchrony { self?.posterImageView.image = image }
            }
        
        AsyncImageFetcher.shared.load(
            in: .search,
            url: viewModel.logoImageURL,
            identifier: viewModel.logoImageIdentifier) { [weak self] image in
                asynchrony { self?.logoImageView.image = image }
            }
    }
    
    private func setupGradientView() {
        if !appliedGradient {
            gradientView.addGradientLayer(
                frame: gradientView.bounds,
                colors: [.black.withAlphaComponent(1.0),
                         .black.withAlphaComponent(0.5),
                         .clear],
                locations: [0.2,
                            0.6,
                            1.0],
                points: [CGPoint(x: 1.0, y: 0.5),
                         CGPoint(x: 0.0, y: 0.5)])
            
            appliedGradient = true
        }
    }
}
