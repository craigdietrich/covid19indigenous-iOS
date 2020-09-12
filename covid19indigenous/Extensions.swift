//
//  Extensions.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 9/12/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

extension UILabel {
    func calculateMaxLines(actualWidth: CGFloat?) -> Int {
        var width = frame.size.width
        if let actualWidth = actualWidth {
            width = actualWidth - 40  // Add padding here if needed
        }
        let maxSize = CGSize(width: width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font!], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}
