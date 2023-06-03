//
//  MediaPlayerObservers.swift
//  netflix
//
//  Created by Zach Bazov on 10/10/2022.
//

import Foundation
import Combine

protocol ObserversProtocol {
    var timeObserverToken: Any! { get }
    var playerItemStatusObserver: NSKeyValueObservation! { get }
    var playerItemFastForwardObserver: NSKeyValueObservation! { get }
    var playerItemReverseObserver: NSKeyValueObservation! { get }
    var playerItemFastReverseObserver: NSKeyValueObservation! { get }
    var playerTimeControlStatusObserver: NSKeyValueObservation! { get }
    var playerItemDidEndPlayingObserver: AnyCancellable! { get }
    var cancelBag: Set<AnyCancellable>! { get }
}

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
