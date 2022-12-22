//
//  DetailPanelViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 04/10/2022.
//

import UIKit

final class DetailPanelViewItemConfiguration {
    private weak var view: DetailPanelViewItem!
    private let myList: MyList
    private let section: Section
    /// Create a panel view item configuration object.
    /// - Parameters:
    ///   - view: Corresponding view.
    ///   - viewModel: Coordinating view model.
    init(view: DetailPanelViewItem, with viewModel: DetailViewModel) {
        self.view = view
        self.myList = viewModel.myList
        self.section = viewModel.myListSection
        self.viewDidConfigure()
        self.viewDidRegisterRecognizers()
    }
    
    deinit {
        view = nil
    }
}

extension DetailPanelViewItemConfiguration {
    private func viewDidRegisterRecognizers() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        view.addGestureRecognizer(tapRecognizer)
    }
    /// Change the view to `selected` state.
    /// Occurs while the `DisplayView` presenting media is contained in the user's list.
    private func selectIfNeeded() {
        guard let tag = Item(rawValue: view.tag) else { return }
        guard let viewModel = view.viewModel else { return }
        if case .myList = tag {
            viewModel.isSelected.value = myList.viewModel.contains(
                viewModel.media,
                in: section.media)
        }
    }
    
    func viewDidConfigure() {
        guard let viewModel = view.viewModel else { return }
        view.imageView.image = UIImage(systemName: viewModel.systemImage)?.whiteRendering()
        view.label.text = viewModel.title
        
        selectIfNeeded()
    }
    
    @objc
    func viewDidTap() {
        guard let tag = Item(rawValue: view.tag) else { return }
        guard let viewModel = view.viewModel else { return }
        switch tag {
        case .myList:
            /// In-case the user doesn't have a list yet.
            if myList.viewModel.list.value.isEmpty {
                myList.viewModel.createList()
            }
            
            let media = viewModel.media!
            myList.viewModel.shouldAddOrRemove(media, uponSelection: viewModel.isSelected.value)
        case .rate: print("rate")
        case .share: print("share")
        }
        /// Animate alpha effect.
        view.setAlphaAnimation(using: view.gestureRecognizers!.first) {
            viewModel.isSelected.value.toggle()
        }
    }
}

extension DetailPanelViewItemConfiguration {
    /// Item representation type.
    enum Item: Int {
        case myList
        case rate
        case share
    }
}

final class DetailPanelViewItem: UIView {
    private(set) var configuration: DetailPanelViewItemConfiguration!
    var viewModel: DetailPanelViewItemViewModel!
    
    fileprivate lazy var imageView = createImageView()
    fileprivate lazy var label = createLabel()
    
    var isSelected = false
    /// Create a panel view item object.
    /// - Parameters:
    ///   - parent: Instantiating view.
    ///   - viewModel: Coordinating view model.
    init(on parent: UIView, with viewModel: DetailViewModel) {
        super.init(frame: parent.bounds)
        self.tag = parent.tag
        parent.addSubview(self)
        self.chainConstraintToCenter(linking: self.imageView, to: self.label)
        self.viewModel = DetailPanelViewItemViewModel(item: self, with: viewModel)
        self.configuration = DetailPanelViewItemConfiguration(view: self, with: viewModel)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    deinit {
        configuration = nil
        viewModel = nil
    }
    
    private func createLabel() -> UILabel {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12.0, weight: .semibold)
        label.textAlignment = .center
        addSubview(label)
        return label
    }
    
    private func createImageView() -> UIImageView {
        let image = UIImage()
        let imageView = UIImageView(image: image)
        imageView.image = image.whiteRendering()
        addSubview(imageView)
        return imageView
    }
}
