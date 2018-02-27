//
//  CreateChannelTableViewCell.swift
//  Fastalk
//
//  Created by Dan Xu on 2/26/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit

class CreateChannelTableViewCell: UITableViewCell {
    @IBOutlet weak var textFieldNewChannelName: UITextField!
    @IBOutlet weak var buttonCreateChannel: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonCreateChannelClicked(_ sender: Any) {
    }
    
}
