//
//  Controller.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

private protocol ControllerObserving {
    func viewObserversDidBind()
    func viewObserversDidUnbind()
}

protocol Controllable {
    associatedtype T: ControllerViewModel
    var viewModel: T! { get set }
}

class Controller<T>: UIViewController, Controllable where T: ControllerViewModel {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var viewModel: T!
    
    func viewDidDeployBehaviors() {
        addBehaviors([BackButtonEmptyTitleNavigationBarBehavior(),
                      BlackStyleNavigationBarBehavior()])
    }
    
    func viewDidDeploySubviews() {}
    
    func viewDidBrandNavigationItemTitleView(withNamedAsset asset: String = "netflix-logo-2") {
        guard navigationController != nil else { return }
        
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
    
    func viewDidLockOrientation(_ mask: UIInterfaceOrientationMask = .portrait) {
        let orientation = DeviceOrientation.shared
        orientation.setLock(orientation: mask)
    }
    
    func viewObserversDidBind() {}
    func viewObserversDidUnbind() {}
}

extension Controller: ControllerObserving {}
