//
//  DetailViewController.swift
//  netflix
//
//  Created by Zach Bazov on 07/09/2022.
//

import AVKit

// MARK: - ControllerProtocol Type

private protocol ControllerProtocol {
    var previewView: PreviewView? { get }
    var dataSource: DetailTableViewDataSource? { get }
    
    func createPreviewView()
    func createDataSource()
}

// MARK: - DetailViewController Type

final class DetailViewController: Controller<DetailViewModel> {
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var previewContainer: UIView!
    
    private(set) var previewView: PreviewView?
    private(set) var dataSource: DetailTableViewDataSource?
    
    deinit {
        print("deinit \(Self.self)")
        
        viewWillDeallocate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deviceWillLockOrientation(.all)
        
        viewWillDeploySubviews()
        viewWillBindObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.shouldScreenRotate()
    }
    
    override func viewWillDeploySubviews() {
        createPreviewView()
        createDataSource()
    }
    
    override func viewWillBindObservers() {
        viewModel.navigationViewState.observe(on: self) { [weak self] state in
            self?.dataSource?.reloadData(at: .collection)
        }
        
        viewModel.season.observe(on: self) { [weak self] season in
            self?.dataSource?.reloadData(at: .collection)
        }
    }
    
    override func viewWillUnbindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.navigationViewState.remove(observer: self)
        viewModel.season.remove(observer: self)
        
        printIfDebug(.success, "Removed `\(Self.self)` observers.")
    }
    
    override func viewWillDeallocate() {
        deviceWillLockOrientation(.portrait)
        
        viewWillUnbindObservers()
        
        previewView = nil
        dataSource = nil
        viewModel = nil
        tableView = nil
    }
}

// MARK: - ControllerProtocol Implementation

extension DetailViewController: ControllerProtocol {
    fileprivate func createPreviewView() {
        previewView = PreviewView(on: previewContainer, with: viewModel)
    }
    
    fileprivate func createDataSource() {
        dataSource = DetailTableViewDataSource(on: tableView, with: viewModel)
    }
}
