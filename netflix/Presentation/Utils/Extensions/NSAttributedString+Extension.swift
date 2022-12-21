//
//  NSAttributedString+Extension.swift
//  netflix
//
//  Created by Zach Bazov on 05/09/2022.
//

import UIKit

extension NSAttributedString {
    typealias Attributes = [NSAttributedString.Key: Any]
    
    static let tabBarItemAttributes: Attributes = [.foregroundColor: UIColor.white,
                                                   .font: UIFont.systemFont(ofSize: 11.0, weight: .bold)]
    
    static let placeholderAttributes: Attributes = [.font: UIFont.systemFont(ofSize: 15.0, weight: .semibold),
                                                    .foregroundColor: UIColor.white]
    static let displayGenresAttributes: Attributes = [.font: UIFont.systemFont(ofSize: 18.0, weight: .bold),
                                                      .foregroundColor: UIColor.white]
    static let displayGenresSeparatorAttributes: Attributes = [.font: UIFont.systemFont(ofSize: 26.0, weight: .heavy),
                                                               .foregroundColor: UIColor.white]
    
    static let newsGenresAttributes: Attributes = [.font: UIFont.systemFont(ofSize: 13.0, weight: .bold),
                                                      .foregroundColor: UIColor.white]
    static let newsGenresSeparatorAttributes: Attributes = [.font: UIFont.systemFont(ofSize: 20.0, weight: .heavy),
                                                               .foregroundColor: UIColor.white]
}
