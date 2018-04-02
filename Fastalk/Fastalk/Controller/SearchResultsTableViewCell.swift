//
//  SearchResultsTableViewCell.swift
//  Fastalk
//
//  Created by Dan Xu on 4/1/18.
//  Copyright © 2018 IOSGroup7. All rights reserved.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelSender: UILabel!
    @IBOutlet weak var labelReceiver: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
