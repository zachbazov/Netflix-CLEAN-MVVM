//
//  RatableCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 08/09/2022.
//

import UIKit

// MARK: - RatableCollectionViewCell class

final class RatableCollectionViewCell: DefaultCollectionViewCell {
    
    private final class TextLayer: CATextLayer {
        override func draw(in ctx: CGContext) {
            ctx.saveGState()
            ctx.translateBy(x: 0.0, y: 0.0)
            super.draw(in: ctx)
            ctx.restoreGState()
        }
    }
    
    private let layerView = UIView()
    private var textLayer = TextLayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    deinit {
        textLayer.removeFromSuperlayer()
        layerView.removeFromSuperview()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLayer.string = nil
    }
    
    private func setupViews() {
        contentView.addSubview(layerView)
        layerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            layerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            layerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            layerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            layerView.heightAnchor.constraint(equalToConstant: bounds.height / 2)
        ])
    }
    
    override func configure(with viewModel: CollectionViewCellItemViewModel) {
        self.viewModel = viewModel
        placeholderLabel.text = viewModel.title
    }
}