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

final class DetailViewController: UIViewController, Controller {
    @IBOutlet private(set) weak var tableView: UITableView!
    @IBOutlet private(set) weak var previewContainer: UIView!
    
    var viewModel: DetailViewModel!
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel?.shouldScreenRotate()
    }
    
    func viewWillDeploySubviews() {
        createPreviewView()
        createDataSource()
    }
    
    func viewWillDeallocate() {
        deviceWillLockOrientation(.portrait)
        
        previewView = nil
        dataSource = nil
        viewModel = nil
        tableView = nil
    }
}

// MARK: - ControllerProtocol Implementation

extension DetailViewController: ControllerProtocol {
    fileprivate func createPreviewView() {
        previewView = PreviewView(with: viewModel)
    }
    
    fileprivate func createDataSource() {
        dataSource = DetailTableViewDataSource(with: viewModel)
    }
}
