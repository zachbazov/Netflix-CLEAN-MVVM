//
//  AlertView.swift
//  netflix
//
//  Created by Zach Bazov on 22/02/2023.
//

import UIKit

// MARK: - ViewProtocol Type

private protocol ViewInput {
    func buttonDidTap(_ sender: UIButton)
    func present(state: AlertView.State?,
                 title: String?,
                 message: String,
                 statusCode: Int?,
                 primaryTitle: String?,
                 secondaryTitle: String?,
                 primaryAction: (() -> Void)?,
                 secondaryAction: (() -> Void)?)
    func handleSwipe(_ gesture: UIPanGestureRecognizer)
}

private protocol ViewOutput {
    var showsAlert: Bool { get }
    var isPresented: Bool { get }
    var isSecondaryActive: Bool { get }
    
    var statusCode: Int { get }
    var initialAlertFrame: CGRect { get }
    
    var primaryAction: (() -> Void)! { get }
    var secondaryAction: (() -> Void)! { get }
    
    var timer: Timer? { get }
    
    var swipeRecognizer: UIPanGestureRecognizer? { get }
    
    var sceneWindow: UIWindow? { get }
    
    func viewDidConfigure()
    func viewDidShow()
    func viewDidHide()
    func viewDidReset()
    func presentationDidFinish()
}

private typealias ViewProtocol = ViewInput & ViewOutput

// MARK: - AlertView Type

final class AlertView: UIView {
    @IBOutlet private(set) weak var contentView: UIView!
    @IBOutlet private(set) weak var imageView: UIImageView!
    @IBOutlet private(set) weak var titleLabel: UILabel!
    @IBOutlet private(set) weak var messageLabel: UILabel!
    @IBOutlet private(set) weak var primaryButton: UIButton!
    @IBOutlet private(set) weak var secondaryButton: UIButton!
    
    static var shared = AlertView()
    
    var showsAlert: Bool = false {
        didSet { showsAlert ? viewDidShow() : viewDidHide() }
    }
    
    var isConfigured: Bool = false
    var isPresented: Bool = false
    var isSecondaryActive: Bool = false
    
    var statusCode: Int = 0
    var initialAlertFrame: CGRect = .zero
    
    var primaryAction: (() -> Void)!
    var secondaryAction: (() -> Void)!
    
    var timer: Timer?
    
    var swipeRecognizer: UIPanGestureRecognizer?
    
    var sceneWindow: UIWindow? { return Application.app.coordinator.window }
    
    private init() {
        super.init(frame: .zero)
        self.nibDidLoad()
        self.viewDidConfigure()
    }
    
    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - ViewInstantiable Implementation

extension AlertView: ViewInstantiable {}

// MARK: - ViewProtocol Implementation

extension AlertView: ViewProtocol {
    fileprivate func viewDidConfigure() {
        guard !isPresented else { return }
        
        sceneWindow?.addSubview(self)
        constraintAlertViewToWindow(withHorizontalMargin: 32.0, height: 64.0)
        
        guard !isConfigured else { return }
        isConfigured = true
        
        contentView.addBlurness()
        contentView.layer.cornerRadius = 16.0
        
        primaryAction = { [weak self] in
            guard let self = self else { return }
            self.showsAlert = false
        }
        
        swipeRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        guard let swipeRecognizer = swipeRecognizer else { return }
        contentView?.addGestureRecognizer(swipeRecognizer)
    }
    
    fileprivate func viewDidShow() {
        isPresented = true
        
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.presentationDidFinish), userInfo: nil, repeats: false)
        
        UIView.animate(withDuration: 0.75,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
            self.alpha = 1.0
            self.transform = CGAffineTransform(translationX: .zero, y: 80.0)
        }, completion: nil)
    }
    
    fileprivate func viewDidHide() {
        isPresented = false
        
        timer?.invalidate()
        
        UIView.animate(withDuration: 0.75,
                       delay: 0.0,
                       options: [.curveEaseInOut],
                       animations: {
            self.alpha = .zero
            self.transform = CGAffineTransform(translationX: .zero, y: -80.0)
        }, completion: { _ in
            mainQueueDispatch(delayInSeconds: 5) {
                guard !self.isPresented else { return }
                self.removeFromSuperview()
            }
        })
    }
    
    fileprivate func viewDidReset() {
        primaryButton.titleLabel?.text = "Dismiss"
        primaryButton.isHidden = false
        secondaryButton.isHidden = true
        titleLabel.isHidden = true
    }
    
    func present(state: State? = .failure,
                 title: String? = nil,
                 message: String,
                 statusCode: Int? = nil,
                 primaryTitle: String? = nil,
                 secondaryTitle: String? = nil,
                 primaryAction: (() -> Void)? = nil,
                 secondaryAction: (() -> Void)? = nil) {
        viewDidConfigure()
        
        guard !isPresented else { return }
        viewDidReset()
        
        showsAlert = true
        messageLabel.text = message
        
        if let title = title {
            titleLabel.isHidden = false
            titleLabel.text = title
        }
        
        if let statusCode = statusCode {
            self.statusCode = statusCode
            if let title = title {
                titleLabel.text = "\(statusCode): \(title)"
            }
        }
        
        if let state = state {
            let successImage = UIImage(systemName: "checkmark.circle")!
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.systemGreen)
            let failureImage = UIImage(systemName: "exclamationmark.shield")!
                .withRenderingMode(.alwaysOriginal)
                .withTintColor(.hexColor("#e50914"))
            imageView.image = state == .success ? successImage : failureImage
        }
        
        if let primaryTitle = primaryTitle {
            primaryButton.setTitle(primaryTitle, for: .normal)
        }
        
        if let secondaryTitle = secondaryTitle {
            secondaryButton.isHidden = false
            secondaryButton.setTitle(secondaryTitle, for: .normal)
        }
        
        if let primaryAction = primaryAction {
            self.primaryAction = primaryAction
        }
        
        if let secondaryAction = secondaryAction {
            self.secondaryAction = secondaryAction
        }
    }
    
    @objc
    fileprivate func presentationDidFinish() {
        showsAlert = false
        
        guard let statusCode = self.statusCode as Int? else { return }
        switch statusCode {
        case 200: self.primaryAction()
        default: break
        }
    }
    
    @objc
    fileprivate func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: contentView)
        switch gesture.state {
        case .began:
            initialAlertFrame = contentView.frame
        case .changed:
            let offsetY = translation.y
            if offsetY > 0 { return }
            viewDidHide()
        default: break
        }
    }
    
    @IBAction
    fileprivate func buttonDidTap(_ sender: UIButton) {
        guard let tag = sender.tag as Int? else { return }
        switch tag {
        case 0: primaryAction()
        case 1: secondaryAction()
        default: break
        }
        
        timer?.invalidate()
    }
}

// MARK: - Status Type

extension AlertView {
    /// Alert state representation type.
    enum State {
        case success
        case failure
    }
}
