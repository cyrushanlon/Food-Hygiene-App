//
//  MyFruitTableViewCell.swift
//  MobileApp
//
//  Created by Cyrus on 01/03/2018.
//  Copyright © 2018 CyrusHanlon. All rights reserved.
//

import UIKit

class HygieneDataTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
