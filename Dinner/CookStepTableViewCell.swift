//
//  CookStepTableViewCell.swift
//  Dinner
//
//  Created by harry bloch on 2/9/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit

class CookStepTableViewCell: UITableViewCell {

    @IBOutlet weak var cookStepCellLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
