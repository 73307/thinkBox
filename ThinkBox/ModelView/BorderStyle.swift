//
//  BorderStyle.swift
//  ThinkBox
//
//  Created by sudhanshu kumar on 09/09/25.
//

import UIKit

extension UIView {
    
    /// Apply border
    func setBorder(color: UIColor = .lightGray, width: CGFloat = 1.0, cornerRadius: CGFloat = 8.0) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
    }
    
    /// Apply shadow
    func setShadow(color: UIColor = .black,
                   opacity: Float = 0.2,
                   offset: CGSize = CGSize(width: 0, height: 2),
                   radius: CGFloat = 4.0) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.masksToBounds = false
    }
    
    /// Apply both border + shadow
    func setBorderWithShadow(borderColor: UIColor = .lightGray,
                             borderWidth: CGFloat = 1.0,
                             cornerRadius: CGFloat = 8.0,
                             shadowColor: UIColor = .black,
                             shadowOpacity: Float = 0.2,
                             shadowOffset: CGSize = CGSize(width: 0, height: 2),
                             shadowRadius: CGFloat = 4.0) {
        setBorder(color: borderColor, width: borderWidth, cornerRadius: cornerRadius)
        setShadow(color: shadowColor, opacity: shadowOpacity, offset: shadowOffset, radius: shadowRadius)
    }
}
