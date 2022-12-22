//
//  TableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

typealias RatedTableViewCell = TableViewCell<RatedCollectionViewCell>
typealias ResumableTableViewCell = TableViewCell<ResumableCollectionViewCell>
typealias StandardTableViewCell = TableViewCell<StandardCollectionViewCell>

final class TableViewCell<T>: UITableViewCell where T: UICollectionViewCell {
    private lazy var collectionView = createCollectionView()
    private var dataSource: HomeCollectionViewDataSource<T>!
    private var layout: CollectionViewLayout!
    
    init(for indexPath: IndexPath, with viewModel: HomeViewModel) {
        super.init(style: .default, reuseIdentifier: TableViewCell<T>.reuseIdentifier)
        let index = HomeTableViewDataSource.Index(rawValue: indexPath.section)!
        let section = viewModel.section(at: index)
        self.dataSource = HomeCollectionViewDataSource(
            on: collectionView,
            section: section,
            viewModel: viewModel)
        self.viewDidLoad()
        self.collectionViewDidLayout(for: section, with: viewModel)
    }
    
    deinit {
        layout = nil
        dataSource = nil
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(T.self)
        contentView.addSubview(collectionView)
        collectionView.constraintToSuperview(contentView)
        return collectionView
    }
    
    private func viewDidLoad() {
        backgroundColor = .black
    }
}

extension TableViewCell {
    /// Setting a layout for the collection view.
    /// - Parameters:
    ///   - section: A section object that represent the cell.
    ///   - viewModel: Coordinating view model.
    func collectionViewDidLayout(for section: Section, with viewModel: HomeViewModel) {
        guard let indices = HomeTableViewDataSource.Index(rawValue: section.id) else { return }
        if case .display = indices {
            ///
        } else if case .rated = indices {
            layout = CollectionViewLayout(layout: .rated, scrollDirection: .horizontal)
            collectionView.setCollectionViewLayout(layout, animated: false)
        } else {
            layout = CollectionViewLayout(layout: .standard, scrollDirection: .horizontal)
            collectionView.setCollectionViewLayout(layout, animated: false)
        }
    }
}

extension TableViewCell {
    enum SortOptions {
        case rating
    }
}
