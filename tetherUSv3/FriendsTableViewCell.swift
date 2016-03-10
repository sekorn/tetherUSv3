//
//  FriendTableViewCell.swift
//  tetherUSv2
//
//  Created by Scott on 2/12/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import UIKit

class FriendTableViewCell: UITableViewCell {
    
    var user:User?
    
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}