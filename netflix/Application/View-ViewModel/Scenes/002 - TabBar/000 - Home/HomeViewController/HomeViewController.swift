//
//  HomeViewController.swift
//  netflix
//
//  Created by Zach Bazov on 31/08/2022.
//

import UIKit

// MARK: - ViewControllerProtocol Type

private protocol ViewControllerProtocol {
    var dataSource: HomeTableViewDataSource? { get }
    var navigationView: NavigationView? { get }
    var browseOverlayView: BrowseOverlayView? { get }
}

// MARK: - HomeViewController Type

final class HomeViewController: Controller<HomeViewModel> {
    @IBOutlet private(set) var tableView: UITableView!
    @IBOutlet private(set) var browseOverlayViewContainer: UIView!
    
    private(set) var dataSource: HomeTableViewDataSource?
    var navigationView: NavigationView?
    var browseOverlayView: BrowseOverlayView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoadBehaviors()
        viewDidBindObservers()
        viewDidDeploySubviews()
        viewModel.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        super.didLockDeviceOrientation(.portrait)
    }
    
    override func viewDidDeploySubviews() {
        setupDataSource()
        setupBrowseOverlayView()
    }
    
    override func viewDidConfigure() {
        guard viewModel.isNotNil else { return }
        
        viewModel?.dataSourceState.value = .all
    }
    
    override func viewDidBindObservers() {
        guard let viewModel = viewModel else { return }
        
        viewModel.dataSourceState.observe(on: self) { [weak self] state in
            guard let self = self else { return }
            self.dataSource?.dataSourceDidChange()
        }
    }
    
    override func viewDidUnbindObservers() {
        guard viewModel.isNotNil else { return }
        
        viewModel.dataSourceState.remove(observer: self)
        
        printIfDebug(.success, "Removed `HomeViewModel` observers.")
    }
}

// MARK: - ViewControllerProtocol Implementation

extension HomeViewController: ViewControllerProtocol {}

// MARK: - Private UI Implementation

extension HomeViewController {
    private func setupDataSource() {
        dataSource = HomeTableViewDataSource(tableView: tableView, viewModel: viewModel)
    }
    
    private func setupBrowseOverlayView() {
        browseOverlayView = BrowseOverlayView(on: browseOverlayViewContainer, with: viewModel)
    }
}

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)

        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)

        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
}
extension UIColor {

    // MARK: - Initialization

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt32 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // MARK: - Computed Properties

    var toHex: String? {
        return toHex()
    }

    // MARK: - From UIColor to String

    func toHex(alpha: Bool = false) -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        var a = Float(1.0)

        if components.count >= 4 {
            a = Float(components[3])
        }

        if alpha {
            return String(format: "%02lX%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255), lroundf(a * 255))
        } else {
            return String(format: "%02lX%02lX%02lX", lroundf(r * 255), lroundf(g * 255), lroundf(b * 255))
        }
    }

}
