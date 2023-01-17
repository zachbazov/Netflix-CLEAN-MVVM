//
//  DetailViewController.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import UIKit

// MARK: - DetailViewController Type

final class DetailViewController: UIViewController {
    
    // MARK: Outlet Properties
    
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var previewContainer: UIView!
    
    // MARK: Properties
    
    var viewModel: DetailViewModel!
    private(set) var previewView: PreviewView!
    private(set) var dataSource: DetailTableViewDataSource!
    
    // MARK: Deinitializer
    
    deinit {
        viewModel.resetOrientation()
        removeObservers()
        previewView = nil
        dataSource = nil
        viewModel = nil
    }
    
    // MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupObservers()
    }
}

// MARK: - UI Setup

extension DetailViewController {
    private func setupSubviews() {
        setupPreviewView()
        setupDataSource()
    }
    
    private func setupPreviewView() {
        previewView = PreviewView(on: previewContainer, with: viewModel)
    }
    
    private func setupDataSource() {
        dataSource = DetailTableViewDataSource(on: tableView, with: viewModel)
    }
}

// MARK: - Observers

extension DetailViewController {
    private func setupObservers() {
        viewModel.navigationViewState.observe(on: self) { [weak self] state in
            self?.dataSource.reloadData(at: .collection)
        }
        viewModel.season.observe(on: self) { [weak self] season in
            self?.dataSource.reloadData(at: .collection)
        }
    }
    
    func removeObservers() {
        if let viewModel = viewModel {
            printIfDebug(.success, "Removed `DetailViewModel` observers.")
            viewModel.navigationViewState.remove(observer: self)
            viewModel.season.remove(observer: self)
        }
    }
}
