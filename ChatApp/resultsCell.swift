//
//  resultsCell.swift
//  ChatApp
//
//  Created by Ugo Besa on 15/01/2016.
//  Copyright © 2016 Ugo Besa. All rights reserved.
//

import UIKit

class resultsCell: UITableViewCell {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let width = UIScreen.mainScreen().bounds.width
        contentView.frame = CGRectMake(0, 0, width, 120) // 120 is also witten in the interface builder
        
        profileImage.center = CGPointMake(60, 60)
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        profileNameLabel.center = CGPointMake(230, 55)    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
