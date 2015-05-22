//
//  UserCell.swift
//  Compass
//
//  Created by Mark on 5/14/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet var userCellImageView: UIImageView!

    @IBOutlet var userCellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
