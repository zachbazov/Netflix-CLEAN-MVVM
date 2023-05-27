//
//  Controller.swift
//  netflix
//
//  Created by Zach Bazov on 05/12/2022.
//

import UIKit

// MARK: - ViewAnimating

protocol ViewAnimating {
    func viewWillAnimateAppearance()
}

protocol Controller: UIViewController,
                     ViewLifecycleBehavior,
                     ViewObserving,
                     ViewModeling,
                     ViewAnimating,
                     DeviceOrienting,
                     NavigationControllerStyling {
    associatedtype ViewModelType: ViewModel
    
    var viewModel: ViewModelType! { get set }
    
    // MARK: ViewLifecycleBehavior
    
    func viewWillLoadBehaviors()
    func viewDidLoadBehaviors()
    func viewWillDeploySubviews()
    func viewDidDeploySubviews()
    func viewHierarchyWillConfigure()
    func viewHierarchyDidConfigure()
    func viewWillConfigure()
    func viewDidConfigure()
    func viewWillTargetSubviews()
    func viewDidTargetSubviews()
    func viewWillDeallocate()
    func viewDidDeallocate()
    
    // MARK: ViewObserving
    
    func viewWillBindObservers()
    func viewDidBindObservers()
    func viewWillUnbindObservers()
    func viewDidUnbindObservers()
    
    // MARK: ViewAnimating
    
    func viewWillAnimateAppearance()
    func viewWillAnimateDisappearance(_ completion: @escaping () -> Void)
}

extension Controller {
    func viewWillLoadBehaviors() {}
    func viewDidLoadBehaviors() {}
    func viewWillDeploySubviews() {}
    func viewDidDeploySubviews() {}
    func viewHierarchyWillConfigure() {}
    func viewHierarchyDidConfigure() {}
    func viewWillConfigure() {}
    func viewDidConfigure() {}
    func viewWillTargetSubviews() {}
    func viewDidTargetSubviews() {}
    func viewWillBindObservers() {}
    func viewDidBindObservers() {}
    func viewWillUnbindObservers() {}
    func viewDidUnbindObservers() {}
    func viewWillDeallocate() {}
    func viewDidDeallocate() {}
    
    func viewWillAnimateAppearance() {
        guard let view = navigationController?.view else { return }
        
        view.alpha = .zero
        view.transform = CGAffineTransform(translationX: view.bounds.width, y: .zero)
        
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: .curveEaseInOut,
            animations: {
                view.transform = .identity
                view.alpha = 1.0
            })
    }
    
    func viewWillAnimateDisappearance(_ completion: @escaping () -> Void) {
        guard let view = navigationController?.view else { return }
        
        UIView.animate(
            withDuration: 0.25,
            delay: .zero,
            options: .curveEaseInOut,
            animations: {
                view.transform = CGAffineTransform(translationX: view.bounds.width, y: .zero)
                view.alpha = .zero
            },
            completion: { _ in
                completion()
            })
    }
}

// MARK: - DeviceOrienting Implementation

extension Controller {
    func deviceWillLockOrientation(_ mask: UIInterfaceOrientationMask = .portrait) {
        let orientation = DeviceOrientation.shared
        orientation.setLock(orientation: mask)
    }
}

// MARK: - NavigationControllerStyling Implementation

extension Controller {
    func titleViewWillConfigure(withAssetNamed asset: String = "netflix-logo-2") {
        let point = CGPoint(x: 0.0, y: 0.0)
        let size = CGSize(width: 80.0, height: 24.0)
        let rect = CGRect(origin: point, size: size)
        
        let titleView = UIView(frame: rect)
        let image = UIImage(named: asset)
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: .zero, y: .zero, width: size.width, height: size.height)
        imageView.center = CGPoint(x: titleView.center.x, y: titleView.center.y)
        
        titleView.addSubview(imageView)
        navigationItem.titleView = titleView
    }
}
