//
//  InAppPurchaseTableViewCell.swift
//  Dinner
//
//  Created by harry bloch on 2/1/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit

class InAppPurchaseTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
