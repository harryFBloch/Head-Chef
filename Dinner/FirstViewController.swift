//
//  FirstViewController.swift
//  Dinner
//
//  Created by harry bloch on 1/2/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit
import Firebase
import StoreKit
import FirebaseCore
import GoogleMobileAds

class FirstViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , SKProductsRequestDelegate, GADBannerViewDelegate {
    
    var productIDs: Array<String> = []

    var productID = NSDictionary()
    var dataBase = NSDictionary()
    var recipes = Array<Recipe>()
    var selectecRecipie = Recipe()
    let menu = DAO.sharedInstance
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-6336588907969710/1803283183"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    @IBOutlet weak var table: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(FirstViewController.reloadMenu), name: NSNotification.Name(rawValue: "reloadMenuTable"), object: nil)
        // Do any additional setup after loading the view, typically from a nib.
        loadPurchasedProducts()
        setupRecipieDictionary()
        if self.menu.menus.count == 0 {
            let menuDefaultBool = isKeyPresentInUserDefaults(key: "menus")
            if menuDefaultBool == true {
                let data = UserDefaults.standard.object(forKey: "menus") as! NSData
                let dictionaryObject = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! NSDictionary
                createMenusArray(dictionary: dictionaryObject)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.table.reloadData()
        checkIFAdsShouldLoad()
    }
    
    func createMenusArray(dictionary: NSDictionary) {
        for key in dictionary {
            let newMenus = Menus()
            newMenus.menuName = key.key as! String
            newMenus.recipeArray = dictionary.object(forKey: key) as! Array<String>
            self.menu.menus.append(newMenus)
        }
        print(self.menu.menus)
    }
    
    
    func setupRecipieDictionary() {
        let recipeDictionaryBool = isKeyPresentInUserDefaults(key: "recipes")
        if recipeDictionaryBool == true {
            let recipeDictionary = UserDefaults.value(forKey: "recipes")
            self.dataBase = recipeDictionary as! NSDictionary
            self.menu.dataBase = recipeDictionary as! NSDictionary
            self.createRecipies()
            if self.menu.menu.count == 0 {
                self.performSegue(withIdentifier: "showMenu", sender: self)
            }
        } else {
            var ref: FIRDatabaseReference!
            ref = FIRDatabase.database().reference()
            ref.child("Recipies").observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary

                self.dataBase = value!
                self.menu.dataBase = value!
                self.createRecipies()
                print("done")
                if self.menu.menu.count == 0 {
                    self.performSegue(withIdentifier: "showMenu", sender: self)
                }
            })
        }
         createProducts()
    }
    
    func reloadMenu() {
        table.reloadData()
    }
    
    func createProducts(){
        var ref: FIRDatabaseReference!
        ref = FIRDatabase.database().reference()
        ref.child("ProductID").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            for (key,_) in value! {
                let productDict = value?.object(forKey: key) as! NSDictionary
                let product = newProduct()
                product.id = productDict.object(forKey: "id") as! String
                product.image = productDict.object(forKey: "image") as! String
                self.productIDs.append(product.id)
                self.menu.productArray.append(product)
            }
            self.requestProductInfo()
        })
    }
    
    func createRecipies() {
        for (key,_) in dataBase {
            let recipieDict = dataBase.object(forKey: key) as! NSDictionary
            let newRecipie = Recipe()
            print(key as! String)
            newRecipie.title = key as! String
            newRecipie.cookTime = recipieDict.object(forKey: "cookTime") as! Double
            newRecipie.prepTime = recipieDict.object(forKey: "prepTime") as! Double
            newRecipie.ingredients = recipieDict.object(forKey: "ingredients") as! NSDictionary
            newRecipie.prep = recipieDict.object(forKey: "prep") as! Array
            newRecipie.prep.remove(at: 0)
            newRecipie.cook = recipieDict.object(forKey: "cook") as! Array
            newRecipie.cook.remove(at: 0)
            newRecipie.author = recipieDict.object(forKey: "author") as! String
            let imageString = recipieDict.object(forKey: "image") as! String
            let image = UIImage(named: imageString)
            newRecipie.image = image!
            recipes.append(newRecipie)
        }
        menu.recipes = self.recipes
        table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FirstViewTableViewCell
        cell.cellLabel.text = self.menu.menu[indexPath.row].title
        cell.cellImage.image = self.menu.menu[indexPath.row].image
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectecRecipie = recipes[indexPath.row]
        performSegue(withIdentifier: "showRecipie", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRecipie" {
            if let destination = segue.destination as? RecipieViewController {
                destination.currentRecipe = self.selectecRecipie
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "Remove") { action, index in
            print("removeTapped")
            self.menu.menu.remove(at: indexPath.row)
            self.menu.recipes[indexPath.row].onMenu = false
            self.table.reloadData()
        }
        more.backgroundColor = .lightGray
        return [more]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        createAlertForMenusName()
    }
    
    func createAlertForMenusName() {
        var inputTextField: UITextField?
        let alert = UIAlertController(title: "Enter Menu Name", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            // Now do whatever you want with inputTextField (remember to unwrap the optional)
            self.saveMenus(menuName: (inputTextField?.text)!)
        }))
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            inputTextField = textField
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func saveMenus(menuName: String) {
        let newMenu = Menus()
        newMenu.menuName = menuName
        for recipe in self.menu.menu {
            newMenu.recipeArray.append(recipe.title)
        }
        
        print(newMenu.menuName)
        self.menu.menus.append(newMenu)
        
        let menusDictionary = NSMutableDictionary()
        for menus in self.menu.menus {
            menusDictionary.setObject(menus.recipeArray, forKey: menus.menuName as NSCopying)
        }
        
        let userDefaults = UserDefaults.standard
        let menusData : Data = NSKeyedArchiver.archivedData(withRootObject: menusDictionary)
        userDefaults.set(menusData, forKey: "menus")
        userDefaults.synchronize()
    }
    
    func wordEntered(alert: UIAlertAction!){
        // store the new word
        
    }
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func requestProductInfo() {
        if SKPaymentQueue.canMakePayments() {
            let productIdentifiers = NSSet(array: productIDs)
            let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
            
            productRequest.delegate = self
            productRequest.start()
        }
        else {
            print("Cannot perform in App purchases")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count != 0 {
            for product in response.products {
                for arrayProduct in self.menu.productArray {
                    if product.productIdentifier == arrayProduct.id {
                        arrayProduct.product = product
                    }
                }
            }
                //reload table data here
        }
        else {
            print("There are no products.")
        }
        if (response.invalidProductIdentifiers.count != 0) {
            print(response.invalidProductIdentifiers.description)
        }
    }
    
    func loadPurchasedProducts() {
        if isKeyPresentInUserDefaults(key: "purchasedProducts") {
            self.menu.purchasedProducts = UserDefaults.standard.value(forKey: "purchasedProducts") as! Array<String>
        }else{
            self.menu.purchasedProducts.append("starter")
            UserDefaults.standard.set(self.menu.purchasedProducts, forKey: "purchasedProducts")
        }
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
            self.table.tableHeaderView?.frame = bannerView.frame
            bannerView.transform = CGAffineTransform.identity
            self.table.tableHeaderView = bannerView
        } 
    }

    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
    }

    
    @IBAction func menuButton(_ sender: Any) {
        performSegue(withIdentifier: "showMenu", sender: self)
    }
    
}

