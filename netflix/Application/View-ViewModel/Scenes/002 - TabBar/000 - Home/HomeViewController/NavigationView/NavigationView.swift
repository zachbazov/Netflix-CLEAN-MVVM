//
//  NavigationView.swift
//  netflix
//
//  Created by Zach Bazov on 06/05/2023.
//

import UIKit

// MARK: - NavigationView Type

final class NavigationView: View<NavigationViewModel> {
    @IBOutlet private weak var navigationContainer: UIView!
    @IBOutlet private weak var segmentContainer: UIView!
    
    var navigationBar: NavigationBarView?
    var segmentControl: SegmentControlView?
    
    var blur: BlurView?
    var gradient: GradientView?
    
    var colors: [UIColor] = []
    
    init(on parent: UIView, with viewModel: HomeViewModel) {
        super.init(frame: .zero)
        
        self.nibDidLoad()
        
        self.viewModel = NavigationViewModel(with: viewModel)
        
        self.navigationBar = NavigationBarView(on: navigationContainer, with: viewModel)
        self.segmentControl = SegmentControlView(on: segmentContainer, with: viewModel)
        
        parent.addSubview(self)
        self.constraintToSuperview(parent)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    /// Style representation type.
    enum Style {
        case blur
        case gradient
    }
    
    func addGradient(with colors: [UIColor]) {
//        guard gradient == nil else { return }
        
        guard let controller = viewModel.coordinator.viewController,
              let container = controller.navigationViewContainer
        else { return }
        
        gradient = GradientView(on: container).applyGradient(with: colors.reversed())
    }
    
    func removeGradient() {
        guard let gradient = gradient else { return }
        
        gradient.remove()
        self.gradient?.removeFromSuperview()
        self.gradient = nil
    }
    
    func addBlur() {
//        guard blur == nil else { return }
        
        guard let controller = viewModel.coordinator.viewController,
              let container = controller.navigationViewContainer
        else { return }
        
        let effect = UIBlurEffect(style: .dark)
        self.blur = BlurView(on: container, effect: effect)
        
        blur?.add()
    }
    
    func removeBlur() {
        guard let blur = blur else { return }
        
        blur.remove()
        
        self.blur = nil
    }
    
    func apply(_ style: NavigationView.Style) {
        guard !colors.isEmpty else { return }
        
        switch style {
        case .blur:
            addBlur()
            removeGradient()
        case .gradient:
            addGradient(with: colors)
            removeBlur()
        }
    }
}

extension NavigationView: ViewInstantiable {}




/*
 //
 //  NavigationView.swift
 //  netflix
 //
 //  Created by Zach Bazov on 06/05/2023.
 //

 import UIKit

 // MARK: - NavigationView Type

 final class NavigationView: UIView {
     @IBOutlet private weak var navigationContainer: UIView!
     @IBOutlet private weak var segmentContainer: UIView!
     
     var navigationBar: NavigationBarView?
     var segmentControl: SegmentControlView?
     
     let style: HomeTableViewDataSourceStyle
     
     init(on parent: UIView, with viewModel: HomeViewModel) {
         self.style = HomeTableViewDataSourceStyle(viewModel: viewModel)
         
         super.init(frame: .zero)
         
         self.nibDidLoad()
         
         self.navigationBar = NavigationBarView(on: navigationContainer, with: viewModel)
         self.segmentControl = SegmentControlView(on: segmentContainer, with: viewModel)
         
         parent.addSubview(self)
         self.constraintToSuperview(parent)
     }
     
     required init?(coder: NSCoder) { fatalError() }
     
     func addGradient(_ colors: [UIColor]) {
         style.setColors(colors)
         style.apply(.gradient)
     }
 }

 extension NavigationView: ViewInstantiable {}





 // MARK: - HomeTableViewDataSourceStyling Type

 private protocol HomeTableViewDataSourceStyling {
     associatedtype Style
     
     var blur: BlurView? { get }
     var gradient: GradientView? { get }
     var colors: [UIColor] { get }
     
     func addGradient()
     func removeGradient()
     func addBlur()
     func removeBlur()
     func setColors(_ colors: [UIColor])
     func apply(_ style: HomeTableViewDataSourceStyle.Style)
 }

 // MARK: - HomeTableViewDataSourceStyle Type

 final class HomeTableViewDataSourceStyle {
     let viewModel: HomeViewModel
     
     var blur: BlurView?
     var gradient: GradientView?
     var colors = [UIColor]()
     
     init(viewModel: HomeViewModel) {
         self.viewModel = viewModel
     }
 }

 // MARK: - HomeTableViewDataSourceStyling Implementation

 extension HomeTableViewDataSourceStyle: HomeTableViewDataSourceStyling {
     /// Style representation type.
     enum Style {
         case blur
         case gradient
     }
     
     fileprivate func addGradient() {
         guard gradient == nil else { return }
         
         guard let controller = viewModel.coordinator?.viewController,
               let container = controller.navigationViewContainer
         else { return }
         
         gradient = GradientView(on: container).applyGradient(with: colors.reversed())
     }
     
     func removeGradient() {
         guard let gradient = gradient else { return }
         
         gradient.remove()
         
         self.gradient = nil
     }
     
     fileprivate func addBlur() {
         guard blur == nil else { return }
         
         guard let controller = viewModel.coordinator?.viewController else { return }
         
         let effect = UIBlurEffect(style: .dark)
         
         blur = BlurView(on: controller.navigationViewContainer, effect: effect)
     }
     
     fileprivate func removeBlur() {
         guard let blur = blur else { return }
         
         blur.view.removeFromSuperview()
         
         self.blur = nil
     }
     
     func apply(_ style: HomeTableViewDataSourceStyle.Style) {
         switch style {
         case .blur:
             addBlur()
             removeGradient()
         case .gradient:
             addGradient()
             removeBlur()
         }
     }
     
     func setColors(_  colors: [UIColor]) {
         self.colors = colors
     }
 }

 */
