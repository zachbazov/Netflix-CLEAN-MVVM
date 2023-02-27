//
//  CollectionViewLayout.swift
//  Netflix-Swift
//
//  Created by Zach Bazov on 28/01/2022.
//

import UIKit

// MARK: - LayoutProtocol Type

private protocol LayoutOutput {
    var layout: CollectionViewLayout.Layout! { get }
    var itemsPerLine: CGFloat { get }
    var lineSpacing: CGFloat { get }
    var width: CGFloat { get }
    var height: CGFloat { get }
}

private typealias LayoutProtocol = LayoutOutput

// MARK: - CollectionViewLayout Type

final class CollectionViewLayout: UICollectionViewFlowLayout, LayoutProtocol {
    fileprivate var layout: Layout!
    fileprivate var itemsPerLine: CGFloat = 3.0
    fileprivate var lineSpacing: CGFloat = 8.0
    
    fileprivate var width: CGFloat {
        get {
            guard let width = super.collectionView!.bounds.width as CGFloat? else { return .zero }
            switch layout {
            case .rated: return width / itemsPerLine - lineSpacing
            case .detail, .navigationOverlay: return width / itemsPerLine - (lineSpacing * itemsPerLine)
            case .descriptive: return width
            case .trailer: return width
            case .news: return width
            case .search: return width
            default: return width / itemsPerLine - (lineSpacing * itemsPerLine)
            }
        }
        set {}
    }
    
    fileprivate var height: CGFloat {
        get {
            switch layout {
            case .rated: return super.collectionView!.bounds.height - lineSpacing
            case .resumable: return super.collectionView!.bounds.height - lineSpacing
            case .standard: return super.collectionView!.bounds.height - lineSpacing
            case .navigationOverlay, .detail: return 146.0
            case .descriptive: return 156.0
            case .trailer: return 224.0
            case .news: return 426.0
            case .search: return 128.0
            default: return .zero
            }
        }
        set {}
    }
    
    convenience init(layout: Layout, scrollDirection: UICollectionView.ScrollDirection? = .horizontal) {
        self.init()
        self.layout = layout
        self.scrollDirection = scrollDirection == .horizontal ? .horizontal : .vertical
    }
    
    // MARK: UICollectionViewFlowLayout Lifecycle
    
    override func prepare() {
        super.prepare()
        
        minimumLineSpacing = lineSpacing
        minimumInteritemSpacing = .zero
        sectionInset = .zero
        itemSize = CGSize(width: width, height: height)
        
        switch layout {
        case .rated:
            minimumLineSpacing = .zero
            sectionInset = .init(top: 0.0, left: 24.0, bottom: 0.0, right: 0.0)
        case .resumable:
            sectionInset = .init(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        case .standard:
            sectionInset = .init(top: 0.0, left: 8.0, bottom: 0.0, right: 0.0)
        case .detail:
            sectionInset = .init(top: 0.0, left: 28.0, bottom: 0.0, right: 28.0)
        case .navigationOverlay:
            sectionInset = .init(top: 0.0, left: 16.0, bottom: 16.0, right: 16.0)
        case .descriptive:
            break
        case .trailer:
            break
        case .news:
            minimumLineSpacing = 0 // set the line spacing to 0
            minimumInteritemSpacing = 0 // set the interitem spacing to 0
            sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // set the section inset to 0
            itemSize = CGSize(width: super.collectionView!.frame.width, height: super.collectionView!.frame.height) // set the size of the cell to the size of the collection view
            sectionInsetReference = .fromSafeArea // set the section inset reference to safe area
            sectionHeadersPinToVisibleBounds = false // set headers pin to visible bounds
            sectionFootersPinToVisibleBounds = false // set footers pin to visible bounds
            estimatedItemSize = .zero // set estimated size to zero
            super.collectionView!.isPagingEnabled = true // enable paging
        case .search:
            break
        default: break
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let oldBounds = collectionView!.bounds as CGRect?,
           oldBounds.size != newBounds.size {
            return true
        }
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
}

// MARK: - Layout Type

extension CollectionViewLayout {
    /// Layout representation type.
    enum Layout {
        case rated
        case resumable
        case standard
        case navigationOverlay
        case detail
        case descriptive
        case trailer
        case news
        case search
    }
}
