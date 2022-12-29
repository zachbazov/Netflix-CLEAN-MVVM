//
//  RatedCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - RatedCollectionViewCell Type

final class RatedCollectionViewCell: CollectionViewCell {
    
    // MARK: TextLayer Type
    
    /// A text layer representation for the cell.
    private final class TextLayer: CATextLayer {
        override func draw(in ctx: CGContext) {
            ctx.saveGState()
            ctx.translateBy(x: .zero, y: .zero)
            super.draw(in: ctx)
            ctx.restoreGState()
        }
    }
    
    // MARK: Properties
    
    private let layerView = UIView()
    private let textLayer = TextLayer()
    
    // MARK: Deinitializer
    
    deinit {
        textLayer.removeFromSuperlayer()
        layerView.removeFromSuperview()
    }
    
    // MARK: CollectionViewCell Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewDidLoad()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textLayer.string = nil
    }
    
    override func viewDidConfigure(with viewModel: CollectionViewCellViewModel) {
        /// Apply base configuartion.
        super.viewDidConfigure(with: viewModel)
        
        guard let indexPath = viewModel.indexPath as IndexPath? else { return }
        /// In-case of first cell index, do nothing.
        if indexPath.row == .zero {
            textLayer.frame = CGRect(x: 0.0, y: -8.0, width: bounds.width, height: 144.0)
        } else {
            /// Else, change the frame horizontal parameter
            /// to make the effect that the text layers collide with other cells.
            textLayer.frame = CGRect(x: -8.0, y: -8.0, width: bounds.width, height: 144.0)
        }
        /// Increase the index path by one, start indexing from 1.
        let index = String(describing: indexPath.row + 1)
        let attributedString = NSAttributedString(
            string: index,
            attributes: [.font: UIFont.systemFont(ofSize: 96.0, weight: .bold),
                         .strokeColor: UIColor.white,
                         .strokeWidth: -2.5,
                         .foregroundColor: UIColor.black.cgColor])
        /// Add the layer to the view hierarchy.
        layerView.layer.insertSublayer(textLayer, at: 1)
        /// Set the text value.
        textLayer.string = attributedString
    }
}

// MARK: - UI Setup

extension RatedCollectionViewCell {
    private func viewDidLoad() {
        contentView.addSubview(layerView)
        layerView.constraintBottom(toParent: self.contentView, withHeightAnchor: bounds.height / 2)
    }
}
