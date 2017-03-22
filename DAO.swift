//
//  DAO.swift
//  Dinner
//
//  Created by harry bloch on 1/10/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit
import StoreKit

class DAO: NSObject {
    var dataBase = NSDictionary()
    var menu = Array<Recipe>()
    var recipes = Array<Recipe>()
    var ingredients = Array<Ingredient>()
    var menus = Array<Menus>()
    var numberOfPeople = Int()
    var productArray: Array<newProduct> = []
    var purchasedProducts: Array<String> = []

    
    //1
    class var sharedInstance: DAO {
        //2
        struct Singleton {
            //3
            static let instance = DAO()
        }
        //4
        return Singleton.instance
    }

}
