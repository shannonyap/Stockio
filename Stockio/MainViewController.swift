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
    
    func createPriceChangeStatusLabel(customFrame: CGRect, font: UIFont, center: CGFloat, cornerRadius: CGFloat, companyCode: String) -> UILabel {
        let priceChangeStatus = UILabel(frame: customFrame)
        priceChangeStatus.center.y = center
        priceChangeStatus.font = font
        priceChangeStatus.backgroundColor = UIColor.lightGrayColor()
        priceChangeStatus.textAlignment = .Center
        priceChangeStatus.clipsToBounds = true
        priceChangeStatus.layer.cornerRadius = cornerRadius
        
        Constants.firebaseRef.child("listOfCompanyNamesAndCodes/\(companyCode)/data").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists() {
                let url = NSURL(string: "https://www.quandl.com/api/v3/datasets/WIKI/" + companyCode + ".json?api_key=sk7mgFNuMAy9JxMi5r-f")
                let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                        
                        let latestDate = json["dataset"]!!["data"]!![0][0] as! String /* 0 denotes the position of the latest Date in the json data */
                        let latestOpenPrice = json["dataset"]!!["data"]!![0][1] as! Float /* 1 denotes the position of the open price in the json data */
                        let latestClosePrice = json["dataset"]!!["data"]!![0][4] as! Float /* 4 denotes the position of the close price in the json data*/
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            let priceChange = latestClosePrice - latestOpenPrice
                            priceChangeStatus.text = String(latestClosePrice - latestOpenPrice)
                            
                            Constants.firebaseRef.child("listOfCompanyNamesAndCodes/\(companyCode)/data").setValue(["latestDate": latestDate, "latestDayPriceChange": priceChangeStatus.text!])
                            self.changeColorOfPriceStatus(priceChangeStatus, valueChange: priceChange)
                        }
                    } catch {
                        print("error serializing JSON: \(error)")
                    }
                }
                
                task.resume()
            } else {
                let latestDateFromData = snapshot.value!["latestDate"] as! String
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.dateFromString(latestDateFromData)
                let calendar = NSCalendar.currentCalendar()
                
                /* If this date falls on a weekend */
                if !calendar.isDateInWeekend(date!) {
                    let parsingDateFormatter = NSDateFormatter()
                    parsingDateFormatter.dateFormat = "yyyy-MM-dd"
                    let yesterday = parsingDateFormatter.stringFromDate(calendar.dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])!)
                    if yesterday == latestDateFromData {
                        Constants.firebaseRef.child("listOfCompanyNamesAndCodes/\(companyCode)/data").observeSingleEventOfType(.Value, withBlock:  { snapshot in
                            
                            let latestDayPriceChange = snapshot.value!["latestDayPriceChange"] as! String
                            dispatch_async(dispatch_get_main_queue()) {
                                priceChangeStatus.text = String(latestDayPriceChange)
                                self.changeColorOfPriceStatus(priceChangeStatus, valueChange: Float(latestDayPriceChange)!)
                            }
                        })
                    }
                }
            }
        })
        return priceChangeStatus
    }
    
    func changeColorOfPriceStatus(priceChangeStatus: UILabel, valueChange: Float) {
        if valueChange < 0 {
            priceChangeStatus.backgroundColor = UIColor(red: 232/255.0, green: 90/255.0, blue: 89/255.0, alpha: 1.0)
        } else if valueChange > 0 {
            priceChangeStatus.backgroundColor = UIColor(red: 86/255.0, green: 188/255.0, blue: 138/255.0, alpha: 1.0)
        }
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
        
        let priceChangeStatus = createPriceChangeStatusLabel(CGRect(x: cell.bounds.size.width * 0.8, y: 0, width: cell.bounds.size.width * 0.175, height: cell.bounds.size.height * 0.7), font: UIFont(name: "BebasNeueLight", size: cell.bounds.size.height * 0.5)!, center: cell.bounds.size.height * 0.65, cornerRadius: cell.bounds.size.height * 0.1, companyCode: cell.textLabel!.text!)
        
        cell.addSubview(priceChangeStatus)
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
