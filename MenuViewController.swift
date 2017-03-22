//
//  MenuViewController.swift
//  Dinner
//
//  Created by harry bloch on 1/10/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit
import GoogleMobileAds

extension String {
    @discardableResult
    func containsText(of textField: String) -> Bool {
        // Precondition
        let text = textField
        let isContained = self.contains(text)
        if isContained { print("\(self) contains \(text)") }
        return isContained
    }
}

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, UISearchBarDelegate {
    let menu = DAO.sharedInstance
    var backBool = false
    var selectecRecipie = Recipe()
    var filteredArray:[Recipe] = []
    var searchActive : Bool = false
    //    var ingredientArray:[] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-6336588907969710/1803283183"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        return adBannerView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
        checkIFAdsShouldLoad()
        searchBar.placeholder = "Search by Ingredient"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func alertForHowManyPeople() {
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "How Many People are you cooking for", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Enter", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            
            let labelText = inputTextField?.text
            if let text = labelText, !text.isEmpty {
                self.menu.numberOfPeople = Int((inputTextField?.text)!)!
                if self.menu.numberOfPeople == 0 {
                    self.menu.numberOfPeople = 1
                }
                print(self.menu.numberOfPeople)
            }
            if self.backBool {
                self.dismiss(animated: true, completion: nil)
            }
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            inputTextField = textField
            inputTextField?.keyboardType = UIKeyboardType.numberPad
            
        })
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButton(_ sender: Any) {
        if self.menu.numberOfPeople == 0 {
            backBool = true
            alertForHowManyPeople()
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuViewTableViewCell
        if searchActive == false{
            if self.menu.recipes[indexPath.row].onMenu == true {
                cell.backgroundColor = .gray
            }else {
                cell.backgroundColor = .white
            }
            cell.cellLabel?.text = self.menu.recipes[indexPath.row].title
            cell.cellImage.image = self.menu.recipes[indexPath.row].image
            return cell
        }else{
            if self.filteredArray[indexPath.row].onMenu == true {
                cell.backgroundColor = .gray
            }else {
                cell.backgroundColor = .white
            }
            cell.cellLabel?.text = self.filteredArray[indexPath.row].title
            cell.cellImage.image = self.filteredArray[indexPath.row].image
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive == false {
            return self.menu.recipes.count
        }else {
            return self.filteredArray.count
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            self.menu.menu.remove(at: indexPath.row)
            self.menu.recipes[indexPath.row].onMenu = false
            tableView.reloadData()
            
            print("remove Button Tapped")
        }
        delete.backgroundColor = .lightGray
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if menu.recipes[indexPath.row].onMenu == true {
            return true
        } else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchActive == true {
            selectecRecipie = filteredArray[indexPath.row]
        }else {
            selectecRecipie = menu.recipes[indexPath.row]
        }
        
        performSegue(withIdentifier: "showRecipe", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipe" {
            if let destination = segue.destination as? RecipieViewController {
                destination.currentRecipe = self.selectecRecipie
            }
        }
    }
    
    
    @IBAction func LoadMenuPressed(_ sender: Any) {
        performSegue(withIdentifier: "loadMenusSegue", sender: self)
        
    }
    
    @IBAction func setNumberOfPeople(_ sender: Any) {
        alertForHowManyPeople()
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
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchActive = false;
        searchBar.resignFirstResponder()
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
        searchBar.showsCancelButton = true
        searchBar.resignFirstResponder()
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredArray = []
        for recipe in self.menu.recipes {
            print(recipe.title)
            var compareBool = false
            for (key,_) in recipe.ingredients {
                let keyString = key as! String
                print(keyString)
                print("\n\n")
                let searchString = searchBar.text?.lowercased()
                if !compareBool {
                    compareBool = keyString.lowercased().containsText(of: searchString!)
                }
            }
            print(recipe.title)
            print(compareBool)
            if compareBool == true {
                filteredArray.append(recipe)
            }else{

            }
        }
        if(filteredArray.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }
    
}
