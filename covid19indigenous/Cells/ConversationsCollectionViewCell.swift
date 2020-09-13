//
//  ConversationsCollectionViewCell.swift
//  covid19indigenous
//
//  Created by Craig Dietrich on 8/31/20.
//  Copyright © 2020 craigdietrich.com. All rights reserved.
//

import UIKit

class ConversationsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var requiresInternetLabel: UILabel!
    @IBOutlet weak var requiresInternetHeight: NSLayoutConstraint!
    @IBOutlet weak var requiresInternetBufferLabel: UILabel!
    @IBOutlet weak var requiresInternetBufferHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
