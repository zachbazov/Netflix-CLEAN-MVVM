//
//  Controller.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - Controller<T> Type

class Controller<T>: UIViewController, ViewModeling where T: ViewModel {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var viewModel: T!
    
    func viewDidLoadBehaviors() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
    
    func viewDidDeploySubviews() {}
    func viewDidConfigure() {}
    func viewDidTargetSubviews() {}
    
    func viewDidBindObservers() {}
    func viewDidUnbindObservers() {}
}

// MARK: - ViewLifecycleBehavior Implementation

extension Controller: ViewLifecycleBehavior {}

// MARK: - ViewObserving Implementation

extension Controller: ViewObserving {}

// MARK: - DeviceOrienting Implementation

extension Controller: DeviceOrienting {
    func didLockDeviceOrientation(_ mask: UIInterfaceOrientationMask = .portrait) {
        let orientation = DeviceOrientation.shared
        orientation.setLock(orientation: mask)
    }
}

// MARK: - NavigationControllerStyling Implementation

extension Controller: NavigationControllerStyling {
    func didConfigureTitleView(withAssetNamed asset: String = "netflix-logo-2") {
        let point = CGPoint(x: 0.0, y: 0.0)
        let size = CGSize(width: 80.0, height: 24.0)
        let rect = CGRect(origin: point, size: size)
        
        let titleView = UIView(frame: rect)
        let image = UIImage(named: asset)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        imageView.center = CGPoint(x: titleView.center.x, y: titleView.center.y)
        
        titleView.addSubview(imageView)
        navigationItem.titleView = titleView
    }
}
