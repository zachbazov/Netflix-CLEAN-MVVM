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

// MARK: - ViewInput Type

private protocol ViewInput {
    associatedtype T: UICollectionViewCell
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: HomeViewModel) -> TableViewCell<T>
    func collectionViewDidLayout(for section: Section, with viewModel: HomeViewModel)
}

private protocol ViewOutput {
    associatedtype T: UICollectionViewCell
    var collectionView: UICollectionView { get }
    var dataSource: HomeCollectionViewDataSource<T>! { get }
    var layout: CollectionViewLayout! { get }
    
    func createCollectionView() -> UICollectionView
    func viewDidLoad()
}

private typealias ViewProtocol = ViewInput & ViewOutput

// MARK: - TableViewCell<T> Type

class TableViewCell<T>: UITableViewCell where T: UICollectionViewCell {
    fileprivate lazy var collectionView: UICollectionView = createCollectionView()
    fileprivate var dataSource: HomeCollectionViewDataSource<T>!
    fileprivate var layout: CollectionViewLayout!
    /// Create a table view cell which holds a collection view.
    /// - Parameters:
    ///   - indexPath: The index path from the table view data source.
    ///   - viewModel: Coordinating view model.
    static func create(on tableView: UITableView,
                       for indexPath: IndexPath,
                       with viewModel: HomeViewModel) -> TableViewCell<T> {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TableViewCell<T>.reuseIdentifier,
            for: indexPath) as? TableViewCell<T> else {
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

// MARK: - ViewProtocol Implementation

extension TableViewCell: ViewProtocol {
    fileprivate func viewDidLoad() {
        backgroundColor = .black
    }
    /// Setting a layout for the collection view.
    /// - Parameters:
    ///   - section: A section object that represent the cell.
    ///   - viewModel: Coordinating view model.
    fileprivate func collectionViewDidLayout(for section: Section, with viewModel: HomeViewModel) {
        guard let indices = HomeTableViewDataSource.Index(rawValue: section.id) else { return }
        switch indices {
        case .display:
            break
        case .rated:
            layout = CollectionViewLayout(layout: .rated, scrollDirection: .horizontal)
            collectionView.setCollectionViewLayout(layout, animated: false)
        default:
            layout = CollectionViewLayout(layout: .standard, scrollDirection: .horizontal)
            collectionView.setCollectionViewLayout(layout, animated: false)
        }
    }
    
    fileprivate func createCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: .init())
        collectionView.backgroundColor = .black
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerNib(T.self)
        contentView.addSubview(collectionView)
        collectionView.constraintToSuperview(contentView)
        return collectionView
    }
}

// MARK: - SortOptions Type

extension TableViewCell {
    /// Sort representation type.
    enum SortOptions {
        case rating
    }
}
