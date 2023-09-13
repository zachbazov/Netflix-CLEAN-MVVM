//
//  PlayButton.swift
//  netflix
//
//  Created by Developer on 07/09/2023.
//

import UIKit

// MARK: - PlayButton Type

final class PlayButton: ButtonView {
    @IBOutlet private weak var image: UIImageView!
    
    override func buttonDidTap() {
        let orientation = DeviceOrientation.shared
        orientation.rotate()
    }
    
    override func buttonWillBeginTapping() {
        super.buttonWillBeginTapping()
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            image.alpha = effectAlpha
        }
    }
    
    override func buttonWillEndTapping() {
        super.buttonWillEndTapping()
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            image.alpha = defaultAlpha
        }
    }
}
