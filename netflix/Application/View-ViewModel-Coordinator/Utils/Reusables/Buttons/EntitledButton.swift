//
//  EntitledButton.swift
//  netflix
//
//  Created by Developer on 06/09/2023.
//

import UIKit

// MARK: - EntitledButton Type

final class EntitledButton: ButtonView {
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var content: UILabel!
    
    override func buttonDidTap() {}
    
    override func buttonWillBeginTapping() {
        super.buttonWillBeginTapping()
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            image.alpha = effectAlpha
            header.alpha = effectAlpha
            content.alpha = effectAlpha
        }
    }
    
    override func buttonWillEndTapping() {
        super.buttonWillEndTapping()
        
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            
            image.alpha = defaultAlpha
            header.alpha = defaultAlpha
            content.alpha = defaultAlpha
        }
    }
}
