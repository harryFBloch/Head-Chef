//
//  cookTableViewCell.swift
//  Dinner
//
//  Created by harry bloch on 1/16/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit

class cookTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    var cellRecipie = Recipe()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cellRecipeLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cellRecipeLabel.text =  String(format: "%@  Cook Time:%1.f",cellRecipie.title, cellRecipie.cookTime)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellRecipie.cookArray[indexPath.row].done {
            cellRecipie.cookArray[indexPath.row].done = false
        } else {
            cellRecipie.cookArray[indexPath.row].done = true
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellRecipie.cookArray.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CookStepCell", for: indexPath) as! CookStepTableViewCell
        let prepStep = cellRecipie.cookArray[indexPath.row]
        let bulletPoint: String = "\u{2022}"
        let cellString = prepStep.step
        let formattedString = String(format: "%@  %@",bulletPoint, cellString)
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: formattedString)
        
        if prepStep.done == false {
            
            attributeString.removeAttribute(NSStrikethroughStyleAttributeName, range: NSMakeRange(0, attributeString.length))
            
        }else {
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        }
        cell.cookStepCellLabel.attributedText = attributeString
        return cell
    }
}
