//
//  MediaPlayerObservers.swift
//  netflix
//
//  Created by Zach Bazov on 10/10/2022.
//

import Foundation
import Combine

// MARK: - MediaPlayerObservers

struct MediaPlayerObservers {
    var timeObserverToken: Any!
    var playerItemStatusObserver: NSKeyValueObservation!
    var playerItemFastForwardObserver: NSKeyValueObservation!
    var playerItemReverseObserver: NSKeyValueObservation!
    var playerItemFastReverseObserver: NSKeyValueObservation!
    var playerTimeControlStatusObserver: NSKeyValueObservation!
    var playerItemDidEndPlayingObserver: AnyCancellable!
    var cancelBag: Set<AnyCancellable>!
}
