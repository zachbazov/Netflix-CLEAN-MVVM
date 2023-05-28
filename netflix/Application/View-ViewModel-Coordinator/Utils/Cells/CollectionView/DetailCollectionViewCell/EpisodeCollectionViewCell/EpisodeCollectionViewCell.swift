//
//  EpisodeCollectionViewCell.swift
//  netflix
//
//  Created by Zach Bazov on 11/10/2022.
//

import UIKit

// MARK: - EpisodeCollectionViewCell Type

final class EpisodeCollectionViewCell: DetailCollectionViewCell {
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    @IBOutlet private weak var downloadButton: UIButton!
    
    // MARK: ViewLifecycleBehavior Implementation
    
    func viewDidLoad() {
        super.dataWillLoad()
        
        viewWillConfigure()
    }
    
    override func viewWillConfigure() {
        super.viewWillConfigure()
        
        setTimestamp(viewModel.length)
        setDescription(viewModel.description)
        
        guard let season = viewModel.season else { return }
        let episode = season.episodes[indexPath.row]
        setTitle(episode.title)
    }
    
    // MARK: ViewProtocol Implementation
    
    func setTimestamp(_ text: String) {
        timestampLabel.text = text
    }
    
    func setDescription(_ text: String) {
        descriptionTextView.text = text
    }
}
