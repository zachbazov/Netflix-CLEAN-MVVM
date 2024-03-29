//
//  UIView+Constraints.swift
//  netflix
//
//  Created by Zach Bazov on 22/09/2022.
//

import UIKit

// MARK: - UIView + Constraints

extension UIView {
    @discardableResult
    func constraintToSuperview(_ view: UIView) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor),
            view.trailingAnchor.constraint(equalTo: trailingAnchor),
            view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        return self
    }
    
    func constraintToCenterSuperview(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func constraintToCenter(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: centerXAnchor),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func constraintCenterToSuperview(in view: UIView, withRadiusValue value: CGFloat) -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: value),
            heightAnchor.constraint(equalToConstant: value),
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return self
    }
    
    func constraintToCenter(_ view: UIView,
                            withLeadingAnchorValue value: CGFloat,
                            sizeInPoints size: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: value),
            view.widthAnchor.constraint(equalToConstant: size),
            view.heightAnchor.constraint(equalToConstant: size),
            view.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func constraintBottom(toParent view: UIView,
                          withHeightAnchor anchorValue: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heightAnchor.constraint(equalToConstant: anchorValue)
        ])
    }
    
    func constraintBottomToSafeArea(toParent view: UIView,
                                    withHeightAnchor anchorValue: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heightAnchor.constraint(equalToConstant: anchorValue)
        ])
    }
    
    func constraintTopAndBottomToSafeArea(toParent view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func constraintBottom(toParent view: UIView,
                          withLeadingAnchor value: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: value),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func constraintBottom(toParent view: UIView,
                          withBottomAnchor value: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: value)
        ])
    }
    
    func constraintBottom(toParent view: UIView,
                          withBottomAnchor value: CGFloat,
                          height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: value),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    func constraintTop(toParent view: UIView, constant: CGFloat, withHeightAnchor anchorValue: CGFloat, horizontalMargin: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalMargin),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalMargin),
            heightAnchor.constraint(equalToConstant: anchorValue)
        ])
    }
    
    func constraintTop(toParent view: UIView, constant: CGFloat, width: CGFloat, height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: constant),
            leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            widthAnchor.constraint(equalToConstant: width),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
    
    func chainConstraintToCenter(linking aView: UIView,
                                 to bView: UIView,
                                 withTopAnchor topAnchorValue: CGFloat? = 8.0,
                                 withBottomAnchor bottomAnchorValue: CGFloat? = 8.0,
                                 withWidth widthValue: CGFloat? = 24.0,
                                 withHeight heightValue: CGFloat? = 24.0) {
        aView.translatesAutoresizingMaskIntoConstraints = false
        bView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aView.topAnchor.constraint(equalTo: topAnchor, constant: topAnchorValue!),
            aView.centerXAnchor.constraint(equalTo: centerXAnchor),
            aView.widthAnchor.constraint(equalToConstant: widthValue!),
            aView.heightAnchor.constraint(equalToConstant: heightValue!),
            aView.bottomAnchor.constraint(equalTo: bView.topAnchor),
            
            bView.centerXAnchor.constraint(equalTo: centerXAnchor),
            bView.centerYAnchor.constraint(equalTo: centerYAnchor),
            bView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomAnchorValue!)
            
        ])
    }
    
    func chainConstraintToSuperview(linking aView: UIView,
                                    to bView: UIView,
                                    withWidthAnchor constraint: NSLayoutConstraint) {
        aView.translatesAutoresizingMaskIntoConstraints = false
        bView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aView.topAnchor.constraint(equalTo: topAnchor, constant: 4.0),
            aView.leadingAnchor.constraint(equalTo: leadingAnchor),
            constraint,
            aView.heightAnchor.constraint(equalToConstant: 3.0),
            
            bView.topAnchor.constraint(equalTo: aView.bottomAnchor),
            bView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func chainConstraintToSuperview(linking aView: UIView,
                                    to bView: UIView,
                                    withLeadingAnchorValue value: CGFloat,
                                    sizeInPoints size: CGFloat) {
        aView.translatesAutoresizingMaskIntoConstraints = false
        bView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            aView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: value),
            aView.widthAnchor.constraint(equalToConstant: size),
            aView.heightAnchor.constraint(equalToConstant: size),
            aView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            bView.leadingAnchor.constraint(equalTo: aView.trailingAnchor, constant: 8.0),
            bView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func constraintAlertViewToWindow(withHorizontalMargin value: CGFloat, height: CGFloat) {
        guard let window = Application.app.coordinator.window else { return }
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: window.topAnchor, constant: value),
            leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: value),
            widthAnchor.constraint(equalToConstant: window.bounds.width - (value * 2)),
            heightAnchor.constraint(equalToConstant: height)
        ])
    }
}
