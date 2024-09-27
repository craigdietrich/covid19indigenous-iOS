//
//  ListTableCell.swift
//  covid19indigenous
//
//  Created by Jalpesh Rajani on 12/08/24.
//  Copyright © 2024 craigdietrich.com. All rights reserved.
//

import UIKit

class ListTableCell: UITableViewCell {

    
    @IBOutlet var listLbl: UILabel!
    @IBOutlet var viewBtn: UIButton!
    @IBOutlet var shareBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.backgroundColor = UIColor(named: "lightBlue")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
