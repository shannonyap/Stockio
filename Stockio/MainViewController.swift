//
//  MainViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/13/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import DrawerController

extension UITableViewDelegate {
    func initTableViewDelegatePresets(tableView: UITableView, tableViewDataSource: UITableViewDataSource, viewController: UIViewController, title: String) {
        tableView.delegate = self
        tableView.dataSource = tableViewDataSource
        viewController.initVCWithNavBarPresets(title)
        tableView.tableFooterView = UIView()
    }
    
    func createPriceChangeStatusLabel(customFrame: CGRect, font: UIFont, center: CGFloat, cornerRadius: CGFloat, companyCode: String, companyKeyCode: String, list: String, databaseName: String, miniGraphData: Array<Dictionary<String, String>>, completion: (result: UILabel, data: Array<Dictionary<String, String>>) -> Void) -> UILabel {
        let priceChangeStatus = UILabel(frame: customFrame)
        priceChangeStatus.center.y = center
        priceChangeStatus.font = font
        priceChangeStatus.backgroundColor = UIColor.lightGrayColor()
        priceChangeStatus.textAlignment = .Center
        priceChangeStatus.clipsToBounds = true
        priceChangeStatus.layer.cornerRadius = cornerRadius
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        Constants.firebaseRef.child("\(list)/\(companyKeyCode)/data").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if !snapshot.exists() {
                self.getFiveDayStockData(dateFormatter, companyCode: companyCode, companyKeyCode: companyKeyCode, priceChangeStatus: priceChangeStatus, miniGraphData: miniGraphData, list: list, databaseName: databaseName, completion: { result, data in
                    completion(result: result, data: data)
                })
            } else {
                let latestDateFromData = snapshot.value!["latestDate"] as! String
                let date = dateFormatter.dateFromString(latestDateFromData)
                let calendar = NSCalendar.currentCalendar()
                
                /* If the latest date is does not fall on a weekend */
                if !calendar.isDateInWeekend(date!) {
                    let parsingDateFormatter = NSDateFormatter()
                    parsingDateFormatter.dateFormat = "yyyy-MM-dd"
                    
                    var yesterday = NSDate()
                    while calendar.isDateInWeekend(yesterday) {
                        yesterday = calendar.dateByAddingUnit(.Day, value: -1, toDate: yesterday, options: [])!
                    }
                    
                    if parsingDateFormatter.stringFromDate(yesterday) == latestDateFromData {
                        let latestDayPriceChange = snapshot.value!["latestDayPriceChange"] as! String
                        dispatch_async(dispatch_get_main_queue()) {
                            priceChangeStatus.text = String(format: "%.3f", Float(latestDayPriceChange)!)
                            self.changeColorOfPriceStatus(priceChangeStatus, valueChange: Float(latestDayPriceChange)!)
                            var graphData = Array<Dictionary<String, String>>()
                            graphData = snapshot.value!["fiveDayStockData"] as! Array<Dictionary<String, String>>
                            completion(result: priceChangeStatus, data: graphData)
                        }
                    } else {
                        /* If today is not the latest date from the DB, update the data in the DB. */
                        self.getFiveDayStockData(dateFormatter, companyCode: companyCode, companyKeyCode: companyKeyCode, priceChangeStatus: priceChangeStatus, miniGraphData: miniGraphData, list: list, databaseName: databaseName, completion: { result, data in
                            completion(result: result, data: data)
                        })
                    }
                }
            }
        })
        return priceChangeStatus
    }
    
    func getFiveDayStockData(dateFormatter: NSDateFormatter, companyCode: String, companyKeyCode: String, priceChangeStatus: UILabel, miniGraphData: Array<Dictionary<String, String>>, list: String, databaseName: String, completion: (result: UILabel, data: Array<Dictionary<String, String>>) -> Void) {
        let calendar = NSCalendar.currentCalendar()
        var latestStockDate = NSDate()
        while calendar.isDateInWeekend(latestStockDate) {
            latestStockDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: latestStockDate, options: [])!
        }
        let endDate = dateFormatter.stringFromDate(latestStockDate)
        let startDate = dateFormatter.stringFromDate(calendar.dateByAddingUnit(.Day, value: -7, toDate: latestStockDate, options: [])!)
        
        let url = NSURL(string: "https://www.quandl.com/api/v3/datasets/\(databaseName)/\(companyCode).json?api_key=sk7mgFNuMAy9JxMi5r-f&start_date=\(startDate)&end_date=\(endDate)")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                if (json["dataset"]!!["data"] as! NSArray).count == 0 {
                    let lastWeekDate =  dateFormatter.stringFromDate(calendar.dateByAddingUnit(.Day, value: -7, toDate: dateFormatter.dateFromString((json["dataset"]!!["newest_available_date"]) as! String)!, options: [])!)
                    let url = NSURL(string: "https://www.quandl.com/api/v3/datasets/\(databaseName)/\(companyCode).json?api_key=sk7mgFNuMAy9JxMi5r-f&start_date=\(lastWeekDate)&end_date=\(json["dataset"]!!["newest_available_date"] as! String)")
                    let newTask = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                        do {
                            let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.updateFiveDayStockDataAndDatesInDB(json["dataset"]!!["data"]!![0][4] as! Float, previousClosePrice: json["dataset"]!!["data"]!![1][4] as! Float, priceChangeStatus: priceChangeStatus, list: list, companyKeyCode: companyKeyCode, latestDate: json["dataset"]!!["data"]!![0][0] as! String, graphData: self.populateWithGraphDataValues(json["dataset"]!!["data"] as! Array<NSArray>))
                                completion(result: priceChangeStatus, data: self.populateWithGraphDataValues(json["dataset"]!!["data"] as! Array<NSArray>))
                            }
                            
                        } catch {
                            print("error serializing JSON: \(error)")
                        }
                    }
                    newTask.resume()
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateFiveDayStockDataAndDatesInDB(json["dataset"]!!["data"]!![0][4] as! Float, previousClosePrice: json["dataset"]!!["data"]!![1][4] as! Float, priceChangeStatus: priceChangeStatus, list: list, companyKeyCode: companyKeyCode, latestDate: json["dataset"]!!["data"]!![0][0] as! String, graphData: self.populateWithGraphDataValues(json["dataset"]!!["data"] as! Array<NSArray>))
                        completion(result: priceChangeStatus, data: self.populateWithGraphDataValues(json["dataset"]!!["data"] as! Array<NSArray>))
                    }
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    func populateWithGraphDataValues(jsonResult: Array<NSArray>) -> Array<Dictionary<String, String>> {
        var graphData = Array<Dictionary<String, String>>()
        for dayStockData in (jsonResult).reverse() {
            graphData.append(["Date": String(dayStockData[0]), "Value": String(dayStockData[1])])
        }
        
        return graphData
    }
    
    func updateFiveDayStockDataAndDatesInDB(latestClosePrice: Float, previousClosePrice: Float, priceChangeStatus: UILabel, list: String, companyKeyCode: String, latestDate: String, graphData: Array<Dictionary<String, String>>) {
        let priceChange = latestClosePrice - previousClosePrice
        priceChangeStatus.text = String(format: "%.3f", priceChange)
        Constants.firebaseRef.child("\(list)/\(companyKeyCode)/data").setValue(["latestDate": latestDate, "latestDayPriceChange": priceChangeStatus.text!])
        self.changeColorOfPriceStatus(priceChangeStatus, valueChange: priceChange)
        
        /* Add the data for the 5-day graph into the DB */
        Constants.firebaseRef.child("\(list)/\(companyKeyCode)/data/fiveDayStockData").setValue(graphData)
    }
    
    func changeColorOfPriceStatus(priceChangeStatus: UILabel, valueChange: Float) {
        if valueChange < 0 {
            priceChangeStatus.backgroundColor = UIColor(red: 232/255.0, green: 90/255.0, blue: 89/255.0, alpha: 1.0)
        } else if valueChange > 0 {
            priceChangeStatus.backgroundColor = UIColor(red: 86/255.0, green: 188/255.0, blue: 138/255.0, alpha: 1.0)
        } else if valueChange == 0 {
            priceChangeStatus.text = "UNCH"
        }
    }
    
    func createMiniGraph(customFrame: CGRect,lineColor: UIColor, cell: UITableViewCell, dataValues: Array<Dictionary<String,String>>, view: UIView, dataSource: BEMSimpleLineGraphDataSource, delegate: BEMSimpleLineGraphDelegate) {
        let miniGraph = BEMSimpleLineGraphView(frame: customFrame)
        miniGraph.center.x = cell.center.x
        miniGraph.center.y = view.bounds.size.height * 0.05
        miniGraph.userInteractionEnabled = false
        miniGraph.dataSource = dataSource
        miniGraph.delegate = delegate
        miniGraph.animationGraphStyle = .None
        miniGraph.colorTop = UIColor.clearColor()
        miniGraph.colorBottom = miniGraph.colorTop
        miniGraph.colorLine = lineColor
        miniGraph.dataValues = NSMutableArray(array: dataValues)
        
        cell.addSubview(miniGraph)
    }
}

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, searchViewControllerDataDelegate, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {
    
    var uid: String = ""
    @IBOutlet weak var tableView: UITableView!
    
    var dictionaryOfCompanies = Dictionary<String, Dictionary<String, String>>()
    var setOfCompanyNames = Array<String>()
    var emptyWatchlist = UILabel()
    var miniGraphData = Array<Dictionary<String, String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableViewDelegatePresets(self.tableView, tableViewDataSource: self, viewController: self, title: "Watchlist")
        addSearchBarButtonItem()

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
        let cell = StockDataTableViewCell(style: .Default, reuseIdentifier: "reuseIdentifier")
        cell.textLabel?.text = dictionaryOfCompanies[self.setOfCompanyNames[indexPath.row]]!["companyCode"]
        cell.textLabel?.font = UIFont(name: "Genome-Thin", size: 17.5)
        cell.companyName = dictionaryOfCompanies[self.setOfCompanyNames[indexPath.row]]!["companyName"]

        let priceChangeStatus = createPriceChangeStatusLabel(CGRect(x: self.view.bounds.size.width * 0.95 - cell.bounds.size.width * 0.175, y: 0, width: cell.bounds.size.width * 0.175, height: cell.bounds.size.height * 0.7), font: UIFont(name: "BebasNeueLight", size: cell.bounds.size.height * 0.5)!, center: self.view.bounds.size.height * 0.05, cornerRadius: cell.bounds.size.height * 0.1, companyCode: cell.textLabel!.text!, companyKeyCode: cell.textLabel!.text!, list: "listOfCompanyNamesAndCodes", databaseName: "WIKI", miniGraphData: self.miniGraphData, completion: { priceChangeLabel, data in
            self.miniGraphData = data
            self.createMiniGraph(CGRect(x: 0, y: 0, width: cell.bounds.size.width * 0.3, height: self.view.bounds.size.height * 0.095),lineColor: priceChangeLabel.backgroundColor!, cell: cell, dataValues: self.miniGraphData, view: self.view, dataSource: self, delegate: self)
        })
        
        cell.addSubview(priceChangeStatus)
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stockGraphVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("StockGraphVC") as! StockGraphPageViewController
        stockGraphVC.currentStockIndexPath = indexPath.row
        stockGraphVC.listOfStocks = tableView.visibleCells
        stockGraphVC.list = "listOfCompanyNamesAndCodes"
        stockGraphVC.dataSetName = "WIKI"
        
        for cell in stockGraphVC.listOfStocks {
            let graph = cell.subviews.filter{$0 is BEMSimpleLineGraphView}.first as! BEMSimpleLineGraphView
            stockGraphVC.setOfGraphData.append(graph.dataValues)
            stockGraphVC.listOfCompanyNames.append((cell as! StockDataTableViewCell).companyName)
            stockGraphVC.listOfCompanyCodes.append((cell as! StockDataTableViewCell).textLabel!.text!)
            stockGraphVC.stockKeyCode.append((cell as! StockDataTableViewCell).textLabel!.text!)
        }
        
        self.presentViewController(stockGraphVC, animated: true, completion: nil)
    }
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return self.miniGraphData.count
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        let dictionaryItem = graph.dataValues[index]
        return CGFloat(NSNumberFormatter().numberFromString(dictionaryItem["Value"] as! String)!)
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
