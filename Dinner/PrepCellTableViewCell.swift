//
//  PrepCellTableViewCell.swift
//  Dinner
//
//  Created by harry bloch on 1/16/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit

class PrepCellTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    var cellRecipie = Recipe()

    @IBOutlet weak var recipieCellLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        recipieCellLabel.text = String(format: "%@  PrepTime:%1.f",cellRecipie.title, cellRecipie.prepTime)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
//        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//        cellImage.isUserInteractionEnabled = true
//        cellImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellRecipie.prepArray[indexPath.row].done {
            cellRecipie.prepArray[indexPath.row].done = false
        } else {
        cellRecipie.prepArray[indexPath.row].done = true
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellRecipie.prepArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "prepStepCell", for: indexPath) as! PrepStepCellTableViewCell
        
        let prepStep = cellRecipie.prepArray[indexPath.row]
        let bulletPoint: String = "\u{2022}"
        let cellString = prepStep.step
        let formattedString = String(format: "%@  %@",bulletPoint, cellString)
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: formattedString)
        
        if prepStep.done == false {
            
            attributeString.removeAttribute(NSStrikethroughStyleAttributeName, range: NSMakeRange(0, attributeString.length))
            
        }else {
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        }
        cell.prepStepCellLabel.attributedText = attributeString
        return cell
    }
}
