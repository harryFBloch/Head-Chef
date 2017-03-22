//
//  LoadMenusViewController.swift
//  Dinner
//
//  Created by harry bloch on 1/25/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit

class LoadMenusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    
    var menu = DAO.sharedInstance
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.menu.menu = []
        createMenuFromMenus(menus: self.menu.menus[indexPath.row])
        self.performSegue(withIdentifier: "showMenuViewFromLoad", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.menus.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "loadMenusCell", for: indexPath)
        cell.textLabel?.text = self.menu.menus[indexPath.row].menuName
        return cell
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createMenuFromMenus(menus: Menus) {
        
        for recipeString in menus.recipeArray {
            for recipe in self.menu.recipes {
                if recipeString == recipe.title {
                    recipe.onMenu = true
                    self.menu.menu.append(recipe)
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.menu.menus.remove(at: indexPath.row)
            self.updateMenusNSUserDefualt()
            self.tableView.reloadData()
        }
        more.backgroundColor = .lightGray
        
        return [more]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
    }
    
    func updateMenusNSUserDefualt() {
        let menusDictionary = NSMutableDictionary()
        for menus in self.menu.menus {
            menusDictionary.setObject(menus.recipeArray, forKey: menus.menuName as NSCopying)
        }
        
        let userDefaults = UserDefaults.standard
        let menusData : Data = NSKeyedArchiver.archivedData(withRootObject: menusDictionary)
        userDefaults.set(menusData, forKey: "menus")
        userDefaults.synchronize()
    }
}
