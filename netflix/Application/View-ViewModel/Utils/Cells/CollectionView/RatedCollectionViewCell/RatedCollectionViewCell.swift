//
//  RatedCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewProtocol {
    associatedtype T
    
    var layerView: UIView { get }
    var textLayer: T { get }
}

// MARK: - RatedCollectionViewCell Type

final class RatedCollectionViewCell: CollectionViewCell {
    fileprivate let layerView = UIView()
    fileprivate let textLayer = TextLayer()
    
    deinit {
        textLayer.removeFromSuperlayer()
        layerView.removeFromSuperview()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewDidLoad()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        textLayer.string = nil
    }
    
    override func viewDidLoad() {
        viewHierarchyWillConfigure()
    }
    
    override func viewHierarchyWillConfigure() {
        layerView
            .addToHierarchy(on: contentView)
            .constraintBottom(toParent: contentView, withHeightAnchor: bounds.height / 2)
    }
    
    override func viewWillConfigure(with viewModel: CollectionViewCellViewModel) {
        super.viewWillConfigure(with: viewModel)
        
        // In-case of first cell index, do nothing.
        if indexPath.row == .zero {
            textLayer.frame = CGRect(x: 8.0, y: -8.0, width: bounds.width, height: 144.0)
        } else {
            /// Else, change the frame horizontal parameter
            /// to make the effect that the text layers collide with other cells.
            textLayer.frame = CGRect(x: -8.0, y: -8.0, width: bounds.width, height: 144.0)
            layerView.transform = CGAffineTransform(translationX: -8.0, y: .zero)
        }
        // Increase the index path by one, start indexing from 1.
        let index = String(describing: indexPath.row + 1)
        let attributedString = NSAttributedString(
            string: index,
            attributes: [.font: UIFont.systemFont(ofSize: 96.0, weight: .bold),
                         .strokeColor: UIColor.white,
                         .strokeWidth: -2.5,
                         .foregroundColor: UIColor.black.cgColor])
        // Add the layer to the view hierarchy.
        layerView.layer.insertSublayer(textLayer, at: 1)
        // Set the text value.
        textLayer.string = attributedString
    }
}

// MARK: - ViewProtocol Implementation

extension RatedCollectionViewCell: ViewProtocol {}

// MARK: - TextLayer Type

extension RatedCollectionViewCell {
    /// A text layer representation for the cell.
    fileprivate final class TextLayer: CATextLayer {
        override func draw(in ctx: CGContext) {
            ctx.saveGState()
            ctx.translateBy(x: .zero, y: .zero)
            super.draw(in: ctx)
            ctx.restoreGState()
        }
    }
}
