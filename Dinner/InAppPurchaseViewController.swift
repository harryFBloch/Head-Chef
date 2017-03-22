//
//  InAppPurchaseViewController.swift
//  Dinner
//
//  Created by harry bloch on 2/1/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit
import StoreKit
import MessageUI


extension SKProduct {
    
    func localizedPrice() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }
    
}

class InAppPurchaseViewController: UIViewController , UITableViewDelegate , UITableViewDataSource , SKPaymentTransactionObserver, MFMailComposeViewControllerDelegate{
    @IBOutlet weak var tableView: UITableView!
    var menu = DAO.sharedInstance
    
    let termsURL = "HeadChefTerms"
    let privacyURL = "HeadChefPrivacy"
    var webViewUrl = String()
    
    var recipes = Array<Recipe>()
    

    var selectedProductIndex: Int!
    var transactionInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PurchaseCell", for: indexPath) as! InAppPurchaseTableViewCell
        let imageString = self.menu.productArray[indexPath.row].image
        let image = UIImage(named:imageString)
        let product = self.menu.productArray[indexPath.row].product
        cell.priceLabel.text = product.localizedPrice()
        cell.cellImage.image = image
        cell.title.text = self.menu.productArray[indexPath.row].product.localizedTitle
        cell.productDescription.text = self.menu.productArray[indexPath.row].product.localizedDescription
        cell.awakeFromNib()
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.productArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProductIndex = indexPath.row
        showActions()
    }
    
    func showActions() {
        if transactionInProgress {
            return
        }
        
        let actionSheetController = UIAlertController(title: String(self.menu.productArray[selectedProductIndex].product.localizedTitle), message: "What do you want to do?", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let buyAction = UIAlertAction(title: "Buy", style: UIAlertActionStyle.default) { (action) -> Void in
            let payment = SKPayment(product: self.menu.productArray[self.selectedProductIndex].product as SKProduct)
            SKPaymentQueue.default().add(payment)
            self.transactionInProgress = true
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
            
        }
        
        actionSheetController.addAction(buyAction)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.purchased:
                print("Transaction completed successfully.")
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                didBuyProduct(transaction: transaction)
               
            case .restored:
                restore(transaction: transaction)
                SKPaymentQueue.default().finishTransaction(transaction)
            case SKPaymentTransactionState.failed:
                print("Transaction Failed");
                SKPaymentQueue.default().finishTransaction(transaction)
                transactionInProgress = false
                
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
      
        print("restore... \(productIdentifier)")
        var repeatProduct = false
        for product in self.menu.purchasedProducts {
            if product == productIdentifier {
                repeatProduct = true
            }
        }
        
        if repeatProduct == false {
            self.menu.purchasedProducts.append(productIdentifier)
            let defaults = UserDefaults.standard
            defaults.set(self.menu.purchasedProducts, forKey: "purchasedProducts")
            defaults.synchronize()
            reloadRecipes()
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    func didBuyProduct(transaction: SKPaymentTransaction) {
         guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        var repeatProduct = false
        for product in self.menu.purchasedProducts {
            if product == productIdentifier {
                repeatProduct = true
            }
        }
        if repeatProduct == false {
        self.menu.purchasedProducts.append(productIdentifier)
        print(self.menu.purchasedProducts)
        let defaults = UserDefaults.standard
        defaults.set(self.menu.purchasedProducts, forKey: "purchasedProducts")
        defaults.synchronize()
        reloadRecipes()
        }
    }
    
    func reloadRecipes() {
        for (key,_) in self.menu.dataBase {
            let recipieDict = self.menu.dataBase.object(forKey: key) as! NSDictionary
            let newRecipie = Recipe()
            newRecipie.title = key as! String
            newRecipie.cookTime = recipieDict.object(forKey: "cookTime") as! Double
            newRecipie.prepTime = recipieDict.object(forKey: "prepTime") as! Double
            newRecipie.ingredients = recipieDict.object(forKey: "ingredients") as! NSDictionary
            newRecipie.prep = recipieDict.object(forKey: "prep") as! Array
            newRecipie.prep.remove(at: 0)
            newRecipie.cook = recipieDict.object(forKey: "cook") as! Array
            newRecipie.cook.remove(at: 0)
            let imageString = recipieDict.object(forKey: "image") as! String
            let image = UIImage(named: imageString)
            newRecipie.image = image!
            newRecipie.author = recipieDict.object(forKey: "author") as! String
            newRecipie.productName = recipieDict.object(forKey: "productName") as! String
            for product in self.menu.purchasedProducts {
                if product == newRecipie.productName {
                    recipes.append(newRecipie)
                }
            }
        }
        menu.recipes = self.recipes
        self.recipes = []
    }
    
    @IBAction func restorePurchasePressed(_ sender: Any) {
         SKPaymentQueue.default().restoreCompletedTransactions()
    }
  
    
    @IBAction func feebackPressed(_ sender: Any) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    @IBAction func privacyPressed(_ sender: Any) {
         webViewUrl = privacyURL
        performSegue(withIdentifier: "showTerms", sender: self)
    }
    
    @IBAction func termsPressed(_ sender: Any) {
        webViewUrl = termsURL
        performSegue(withIdentifier: "showTerms", sender: self)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["harryfbloch@Gmail.com"])
        mailComposerVC.setSubject("Head Chef Feedback")
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTerms" {
            if let destination = segue.destination as? TermsViewController {
               destination.urlString = webViewUrl
            }
        }
    }
    
}
