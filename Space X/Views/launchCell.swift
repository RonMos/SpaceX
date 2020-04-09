//
//  launchCell.swift
//  Space X
//
//  Created by Andrey on 08/04/2020.
//  Copyright © 2020 Andrey. All rights reserved.
//

import UIKit

class launchCell: UITableViewCell {
    
    @IBOutlet weak var flightNumberLabel: UILabel!
    @IBOutlet weak var missionNameLabel: UILabel!
    @IBOutlet weak var launchDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
