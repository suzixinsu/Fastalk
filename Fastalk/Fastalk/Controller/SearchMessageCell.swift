//
//  SearchMessageCell.swift
//  Fastalk
//
//  Created by Dan Xu on 3/30/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit

class SearchMessageCell: UITableViewCell {
    @IBOutlet weak var textFieldSearchKeyword: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
