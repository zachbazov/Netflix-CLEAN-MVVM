//
//  TableViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 13/09/2022.
//

import UIKit

// MARK: - Cell Types

typealias RatedTableViewCell = TableViewCell<RatedCollectionViewCell>
typealias ResumableTableViewCell = TableViewCell<ResumableCollectionViewCell>
typealias StandardTableViewCell = TableViewCell<StandardCollectionViewCell>

// MARK: - TableViewCell<T> Type

class TableViewCell<T>: UITableViewCell where T: UICollectionViewCell {
    private lazy var collectionView = createCollectionView()
    private var dataSource: HomeCollectionViewDataSource<T>!
    private var layout: CollectionViewLayout!
    /// Create a table view cell which holds a collection view.
    /// - Parameters:
    ///   - indexPath: The index path from the table view data source.
    ///   - viewModel: Coordinating view model.
    static func create(on tableView: UITableView, for indexPath: IndexPath, with viewModel: HomeViewModel) -> TableViewCell<T> {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell<T>.reuseIdentifier, for: indexPath) as? TableViewCell<T> else {
            fatalError()
        }
        let index = HomeTableViewDataSource.Index(rawValue: indexPath.section)!
        let section = viewModel.section(at: index)
        cell.dataSource = HomeCollectionViewDataSource(
            on: cell.collectionView,
            section: section,
            viewModel: viewModel)
        cell.viewDidLoad()
        cell.collectionViewDidLayout(for: section, with: viewModel)
        return cell
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - UI Setup

extension TableViewCell {
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

// MARK: - Methods

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

// MARK: - SortOptions Type

extension TableViewCell {
    /// Sort representation type.
    enum SortOptions {
        case rating
    }
}
