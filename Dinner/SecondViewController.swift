//
//  SecondViewController.swift
//  Dinner
//
//  Created by harry bloch on 1/2/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//
import GoogleMobileAds
import UIKit

class SecondViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    var menu = DAO.sharedInstance
    var tempRecipeArray = Array<Ingredient>()
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-6336588907969710/1803283183"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        checkIFAdsShouldLoad()
        createIngredientsArray()
        
        if self.menu.numberOfPeople == 0 {
            self.menu.numberOfPeople = 2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func createIngredientsArray() {
        var doubleAmount = Double()
        for recipe in menu.menu {
            for (key,_) in recipe.ingredients {
                let ingredient = Ingredient()
                let ingredientDictionary = recipe.ingredients.object(forKey: key) as! NSDictionary
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
        }
        combineLikeIngredients()
    }
    
    func combineLikeIngredients() {
        var recipeRepeat = Bool()
        for ingredient in tempRecipeArray {
            recipeRepeat = false
            for arrayIngredient in menu.ingredients {
                if ingredient.name == arrayIngredient.name && ingredient.measurment == arrayIngredient.measurment {
                    arrayIngredient.amount += ingredient.amount
                    recipeRepeat = true
                }
            }
            if recipeRepeat == false {
                menu.ingredients.append(ingredient)
            }
        }
        setAmountForIngredientsBasedOnAmountOfPeople()
    }
    
    
    func setAmountForIngredientsBasedOnAmountOfPeople() {
        let multiplyerInt = Double(self.menu.numberOfPeople) * 0.5
        for ingredients in self.menu.ingredients {
            ingredients.amount = ingredients.amount * multiplyerInt
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.ingredients.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if menu.ingredients[indexPath.row].isBought {
            menu.ingredients[indexPath.row].isBought = false
            
        }else{
            menu.ingredients[indexPath.row].isBought = true
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let ingredient = self.menu.ingredients[indexPath.row]
        if ingredient.isBought == false {
            let formattedString = String(format: "%.1f %@   %@",ingredient.amount, ingredient.measurment, ingredient.name )
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: formattedString)
            attributeString.removeAttribute(NSStrikethroughStyleAttributeName, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
            
        }else {
            let formattedString = String(format: "%.1f %@   %@",ingredient.amount, ingredient.measurment, ingredient.name )
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: formattedString)
            attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
            cell.textLabel?.attributedText = attributeString
        }
        return cell
    }
    
    func checkIFAdsShouldLoad() {
        var removeAds = false
        for productID in menu.purchasedProducts {
            if productID == "com.harryfbloch.Dinner.RemoveAds" {
                removeAds = true
                adBannerView.removeFromSuperview()
            }
        }
        if removeAds == false {
            adBannerView.load(GADRequest())
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.tableHeaderView?.frame = bannerView.frame
            bannerView.transform = CGAffineTransform.identity
            self.tableView.tableHeaderView = bannerView
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
}







