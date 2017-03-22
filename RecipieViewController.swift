//
//  RecipieViewController.swift
//  Dinner
//
//  Created by harry bloch on 1/9/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit

class RecipieViewController: UIViewController {
    var currentRecipe = Recipe()
    let menu = DAO.sharedInstance
    var tempRecipeArray = Array<Ingredient>()

    
    @IBOutlet weak var image: UIImageView!
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var addToMenuButton: UIBarButtonItem!
    @IBAction func addToMenu(_ sender: Any) {
        if currentRecipe.onMenu == true {
            for recipe in menu.recipes {
                if recipe.title == currentRecipe.title {
                    recipe.onMenu = false
                }
            }
            for i in 0..<menu.menu.count {
                if menu.menu[i].title == currentRecipe.title {
                    menu.menu.remove(at: i)
                }
            }
        }else{
         menu.menu.append(currentRecipe)
            for recipe in menu.recipes {
                if recipe.title == currentRecipe.title {
                    recipe.onMenu = true
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadMenuTable"), object: nil)
        self.dismiss(animated: true, completion: nil)
            }
   
    @IBOutlet weak var recipieTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var cookLabel: UITextView!
    @IBOutlet weak var cookTimeLabel: UILabel!
    @IBOutlet weak var prepLabel: UITextView!
    @IBOutlet weak var prepTimeLabel: UILabel!
    @IBOutlet weak var ingredientsLabel: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        if currentRecipe.onMenu == true {
            addToMenuButton.title = "Remove From Menu"
        }
        
        recipieTitleLabel.text = currentRecipe.title
        authorLabel.text = currentRecipe.author
        cookTimeLabel.text = String(format:"%.f mins", currentRecipe.cookTime)
        prepTimeLabel.text = String(format: "%.f mins", currentRecipe.prepTime)
        createIngredientsArray()
        setPrepLabel()
        setCookLabel()
        image.image = currentRecipe.image
    }
    
    func setCookLabel() {
        var formattedString = String()
        var labelString = String()
        let bulletPoint: String = "\u{2022}"
        
        for step in currentRecipe.cook {
            let stepString = String(describing: step)
            formattedString = String(format: "%@ %@\n",bulletPoint, stepString)
            labelString.append(formattedString)
        }
        cookLabel.text = labelString

    }
    
    func setPrepLabel() {
        var formattedString = String()
        var labelString = String()
        let bulletPoint: String = "\u{2022}"
        
        for step in currentRecipe.prep {
            let stepString = String(describing: step)
            formattedString = String(format: "%@ %@\n",bulletPoint, stepString)
            labelString.append(formattedString)
        }
        prepLabel.text = labelString
    }
    
    func setIngredientsLabel() {
        var labelString = String()
        var formattedString = String()
        for ingredient in tempRecipeArray {
            let bulletPoint: String = "\u{2022}"
            formattedString = String(format:"%@ %.1f %@  %@\n", bulletPoint , ingredient.amount, ingredient.measurment, ingredient.name)
            labelString.append(formattedString)
        }
        ingredientsLabel.text = labelString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createIngredientsArray() {
        var doubleAmount = Double()
            for (key,_) in currentRecipe.ingredients {
                let ingredient = Ingredient()
                let ingredientDictionary = currentRecipe.ingredients.object(forKey: key) as! NSDictionary
                let measurment = ingredientDictionary.object(forKey: "measurment") as! String
                let ingredientName = key as! String
                let amount : String?
                ingredient.name = ingredientName
                ingredient.measurment = measurment
                amount = ingredientDictionary.object(forKey: "amount") as? String!
                if amount != " " {
                    //doubleAmount
                    if amount == nil {
                        doubleAmount = ingredientDictionary.object(forKey: "amount") as! Double
                        ingredient.amount = doubleAmount
                        //string amount
                    }else{
                        ingredient.amount = Double(amount!)!
                    }
                    //no amount
                }else{
                    ingredient.amount = 0.0
                }
                tempRecipeArray.append(ingredient)
            }
        
        setAmountForIngredientsBasedOnAmountOfPeople()
    }

    
    func setAmountForIngredientsBasedOnAmountOfPeople() {
        var people = self.menu.numberOfPeople
        if people == 0 {
            people = 2
        }
        let multiplyerInt = Double(people) * 0.5
        for ingredients in tempRecipeArray {
            ingredients.amount = ingredients.amount * multiplyerInt
        }
        setIngredientsLabel()
    }
}
