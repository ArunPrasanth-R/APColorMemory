//
//  HighScoreTableViewCell.swift
//  ColorMemory
//
//  Created by Ahamed Muqthar M K on 26/01/16.
//  Copyright © 2016 ArunPrasanth R. All rights reserved.
//

import UIKit

class HighScoreTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
