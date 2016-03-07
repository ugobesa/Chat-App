//
//  messageCell.swift
//  ChatApp
//
//  Created by Ugo Besa on 20/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit

class messageCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
