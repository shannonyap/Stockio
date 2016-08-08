//
//  MutualFundsViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 8/7/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class MutualFundsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, searchViewControllerDataDelegate {

    @IBOutlet weak var tableView: UITableView!
    var uid = ""
    var dictionaryOfMutualFunds = Dictionary<String, Dictionary<String, String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableViewDelegatePresets(self.tableView, tableViewDataSource: self, viewController: self, title: "Mutual Funds")
        addSearchBarButtonItem()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        if self.dictionaryOfMutualFunds.count == 0 {
            
        } else {
            self.tableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addSearchBarButtonItem() {
        let barButton = UIBarButtonItem(image: UIImage(named: "searchIcon"), style: .Plain, target: self, action: #selector(didSelectSearchBarButtonItem(_:)))
        barButton.tintColor = UIColor.blackColor()
        self.navigationItem.setRightBarButtonItem(barButton, animated: true)
    }
    
    func didSelectSearchBarButtonItem(sender: UIBarButtonItem) {
        let searchVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchVC") as! SearchViewController
        searchVC.delegate = self
        searchVC.financialType = "Mutual Fund"
        searchVC.list = "listOfMutualFunds"
        searchVC.firebaseCode = "indexCode"
        searchVC.firebaseName = "indexName"
        
        self.presentViewController(searchVC, animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dictionaryOfMutualFunds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = StockDataTableViewCell(style: .Default, reuseIdentifier: "reuseIdentifier")
        cell.textLabel?.text = "jdkfsafd"
        return cell
    }
    
    func sendCompanyNameToMainVC(companyName: Dictionary<String, Dictionary<String, String>>) {
        self.dictionaryOfMutualFunds[companyName.keys.first!] = companyName[companyName.keys.first!]
        let fundCode = companyName[companyName.keys.first!]
        print(fundCode![fundCode!.keys.first!]!.componentsSeparatedByString("_")[1])
        Constants.firebaseRef.child("users/\(uid)/MutualFundsWatchList/\(fundCode![fundCode!.keys.first!]!.componentsSeparatedByString("_")[1])").setValue(companyName[companyName.keys.first!])
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
