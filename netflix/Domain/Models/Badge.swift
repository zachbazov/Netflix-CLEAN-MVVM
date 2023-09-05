//
//  Badge.swift
//  netflix
//
//  Created by Developer on 21/08/2023.
//

import UIKit

// MARK: - Badge Type

struct Badge: Badgable {
    let badgeType: BadgeType
}

// MARK: - BadgeType Type

enum BadgeType {
    case edit
    case delete
}
