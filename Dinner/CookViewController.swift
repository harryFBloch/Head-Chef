//
//  CookViewController.swift
//  Dinner
//
//  Created by harry bloch on 1/16/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CookViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate{
    var menu = DAO.sharedInstance
    
    var selectedRecipe = Recipe()
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-6336588907969710/1803283183"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        createCookStepsArray()
        checkIFAdsShouldLoad()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRecipe = menu.menu[indexPath.row]
        performSegue(withIdentifier: "showRecipeFromCook", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.menu.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CookTableCell", for: indexPath) as! cookTableViewCell
        cell.cellRecipie = self.menu.menu[indexPath.row]
        cell.awakeFromNib()
        cell.cellImage.image = self.menu.menu[indexPath.row].image
        return cell
    }
    
    func createCookStepsArray() {
        
        for recipe in menu.menu {
            for string in recipe.cook {
                let prepString = String(describing: string)
                let prepStep = PrepStep()
                prepStep.done = false
                prepStep.step = prepString
                recipe.cookArray.append(prepStep)
            }
        }
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        
        // Reposition the banner ad to create a slide down effect
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        UIView.animate(withDuration: 0.5) {
            self.tableView.tableHeaderView?.frame = bannerView.frame
            bannerView.transform = CGAffineTransform.identity
            self.tableView.tableHeaderView = bannerView
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipeFromCook" {
            if let destination = segue.destination as? RecipieViewController {
                destination.currentRecipe = self.selectedRecipe
            }
        }
    }
}
