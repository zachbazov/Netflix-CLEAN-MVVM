//
//  DetailViewController.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import UIKit

// MARK: - ControllerProtocol Type

private protocol ControllerOutput {
    var previewView: PreviewView! { get }
    var dataSource: DetailTableViewDataSource! { get }
}

private typealias ControllerProtocol = ControllerOutput

// MARK: - DetailViewController Type

final class DetailViewController: Controller<DetailViewModel> {
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var previewContainer: UIView!
    
    private(set) var previewView: PreviewView!
    private(set) var dataSource: DetailTableViewDataSource!
    
    deinit {
        viewModel.resetOrientation()
        viewDidUnbindObservers()
        previewView = nil
        dataSource = nil
        viewModel = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidDeploySubviews()
        viewDidBindObservers()
    }
    
    override func viewDidDeploySubviews() {
        setupPreviewView()
        setupDataSource()
    }
    
    override func viewDidBindObservers() {
        viewModel.navigationViewState.observe(on: self) { [weak self] state in
            self?.dataSource.reloadData(at: .collection)
        }
        viewModel.season.observe(on: self) { [weak self] season in
            self?.dataSource.reloadData(at: .collection)
        }
    }
    
    override func viewDidUnbindObservers() {
        if let viewModel = viewModel {
            printIfDebug(.success, "Removed `DetailViewModel` observers.")
            viewModel.navigationViewState.remove(observer: self)
            viewModel.season.remove(observer: self)
        }
    }
}

// MARK: - ControllerProtocol Implementation

extension DetailViewController: ControllerProtocol {}

// MARK: - Private UI Implementation

extension DetailViewController {
    private func setupPreviewView() {
        previewView = PreviewView(on: previewContainer, with: viewModel)
    }
    
    private func setupDataSource() {
        dataSource = DetailTableViewDataSource(on: tableView, with: viewModel)
    }
}
