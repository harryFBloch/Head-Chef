//
//  Recipie.swift
//  Dinner
//
//  Created by harry bloch on 1/6/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import Foundation
import UIKit

class Recipe: NSObject {
    var title = String()
    var ingredients = NSDictionary()
    var author = String()
    var prepTime = Double()
    var cookTime = Double()
    var prep = Array<Any>()
    var cook = Array<Any>()
    var course = String()
    var onMenu = Bool()
    var prepArray = Array<PrepStep>()
    var cookArray = Array<PrepStep>()
    var productName = String()
    var image = UIImage()
    
    override init() {
        super.init()
    }
}
