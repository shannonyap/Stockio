//
//  MainViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/13/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import DrawerController

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, searchViewControllerDataDelegate {
    
    var uid: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    var dictionaryOfCompanies = Dictionary<String, Dictionary<String, String>>()
    var setOfCompanyNames = Array<String>()
    var emptyWatchlist = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        initVCWithNavBarPresets("Watchlist")
        addSearchBarButtonItem()
        
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .None
        self.tableView.allowsSelection = false
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        Constants.firebaseRef.child("users/\(uid)/watchlist").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.exists() {
                self.dictionaryOfCompanies = snapshot.value as! Dictionary<String, Dictionary<String, String>>
                
                self.setOfCompanyNames = []
                for keys in self.dictionaryOfCompanies {
                    self.setOfCompanyNames.append(keys.0)
                }
                
                let watchListLabel = self.view.subviews.filter{$0 is UILabel}

                if self.dictionaryOfCompanies.count == 0 && watchListLabel.count < 1 {
                    self.displayEmptyWatchListLabel()
                } else if self.dictionaryOfCompanies.count != 0 {
                    self.emptyWatchlist.removeFromSuperview()
                }
                self.tableView.reloadData()
            } else {
                self.displayEmptyWatchListLabel()
            }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        if dictionaryOfCompanies.count != 0 {
            Constants.firebaseRef.child("users/\(uid)/watchlist").setValue(dictionaryOfCompanies)
        }
    }
    
    func displayEmptyWatchListLabel() {
        self.emptyWatchlist = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.3))
        self.emptyWatchlist.center = self.view.center
        self.emptyWatchlist.text = "Your Watchlist is empty"
        self.emptyWatchlist.textAlignment = .Center
        self.emptyWatchlist.font = UIFont(name: "BebasNeueLight", size: 30.0)
        self.view.addSubview(self.emptyWatchlist)
    }

    func addSearchBarButtonItem() {
        let barButton = UIBarButtonItem(image: UIImage(named: "searchIcon"), style: .Plain, target: self, action: #selector(didSelectSearchBarButtonItem(_:)))
        barButton.tintColor = UIColor.blackColor()
        self.navigationItem.setRightBarButtonItem(barButton, animated: true)
    }
    
    func didSelectSearchBarButtonItem(sender: UIBarButtonItem) {
        let searchVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchVC") as! SearchViewController
        searchVC.delegate = self
        self.presentViewController(searchVC, animated: true, completion: nil)
    }
    
    func sendCompanyNameToMainVC(companyName: Dictionary<String, Dictionary<String, String>>) {
        self.dictionaryOfCompanies[companyName.keys.first!] = companyName[companyName.keys.first!]
        Constants.firebaseRef.child("users/\(uid)/watchlist/\(companyName.keys.first!)").setValue(companyName[companyName.keys.first!])
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dictionaryOfCompanies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "reuseIdentifier")
        let cellBorderLine = UIView(frame: CGRect(x: 0, y: self.view.bounds.size.height * 0.1, width: self.view.bounds.size.width * 0.95, height: 0.5))
        cellBorderLine.center.x = self.view.center.x
        cellBorderLine.backgroundColor = UIColor.grayColor()
        cell.textLabel?.text = dictionaryOfCompanies[self.setOfCompanyNames[indexPath.row]]!["companyCode"]
        cell.textLabel?.font = UIFont(name: "Genome-Thin", size: 17.5)
        
        cell.addSubview(cellBorderLine)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.bounds.size.height * 0.1
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let companyCode = self.setOfCompanyNames[indexPath.row]
            self.dictionaryOfCompanies.removeValueForKey(self.setOfCompanyNames[indexPath.row])
            self.setOfCompanyNames.removeAtIndex(indexPath.row)
            Constants.firebaseRef.child("users/\(self.uid)/watchlist/\(companyCode)").removeValue()
            tableView.reloadData()
        }
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
