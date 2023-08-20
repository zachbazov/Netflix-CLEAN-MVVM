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
        
        tableView.removeFromSuperview()
        
        previewView = nil
        dataSource = nil
        viewModel = nil
        tableView = nil
        
//        restoreHomeViewControllerNavigationStyle()
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

//

//extension DetailViewController {
//    fileprivate func restoreHomeViewControllerNavigationStyle() {
//        guard let controller = Application.app.coordinator.tabCoordinator?.home?.viewControllers.first as? HomeViewController else { return }
//
//        if controller.navigationView?.gradient == nil || controller.navigationView?.blur == nil {
//            controller.navigationView?.segmentControl?.origin(y: .zero)
//            controller.navigationViewContainerHeight.constant = 160.0
//            controller.navigationView?.segmentControl?.alpha = 1.0
//
//            mainQueueDispatch {
//                if controller.tableView.contentOffset.y < .zero {
//                    controller.navigationView?.apply(.gradient)
//                } else {
//                    controller.navigationView?.apply(.blur)
//                }
//
//                controller.navigationView?.layoutIfNeeded()
//            }
//        }
//    }
//}
