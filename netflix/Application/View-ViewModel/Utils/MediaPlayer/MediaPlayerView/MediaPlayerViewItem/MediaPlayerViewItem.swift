//
//  MediaPlayerViewItem.swift
//  netflix
//
//  Created by Zach Bazov on 06/10/2022.
//

import AVKit

// MARK: - MediaPlayerViewItem Type

final class MediaPlayerViewItem: AVPlayerItem {
    override init(asset: AVAsset, automaticallyLoadedAssetKeys: [String]?) {
        super.init(asset: asset, automaticallyLoadedAssetKeys: automaticallyLoadedAssetKeys)
    }
    
    convenience init?(with media: Media) {
        guard let path = media.type == Media.MediaType.film.rawValue
                ? media.resources.previewUrl
                : media.resources.trailers.first,
              let url = URL(string: path)
        else { return nil }
        
        let asset = AVAsset(url: url)
        
        self.init(asset: asset, automaticallyLoadedAssetKeys: nil)
    }
}
