//
//  MenuViewTableViewCell.swift
//  Dinner
//
//  Created by harry bloch on 3/1/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit

class MenuViewTableViewCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
