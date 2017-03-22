//
//  TermsViewController.swift
//  Dinner
//
//  Created by harry bloch on 3/15/17.
//  Copyright © 2017 harry bloch. All rights reserved.
//

import UIKit

class TermsViewController: UIViewController {

    var urlString = String()
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let htmlFile = Bundle.main.path(forResource: urlString, ofType: "html")
        let html = try! String(contentsOfFile: htmlFile!, encoding: String.Encoding.utf8)
        self.webView.loadHTMLString(html, baseURL: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
