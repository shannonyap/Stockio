//
//  StockContentViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 8/1/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class StockContentViewController: UIViewController, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {

    var graphView = BEMSimpleLineGraphView()
    var dateLabel = UILabel()
    var stockPriceLabel = UILabel()
    var stockName: String!
    var stockCode: String!
    var fiveDayStockData: NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.topItem?.title = stockName

        self.dateLabel = createLabels(CGRect(x: 0, y: navBar.bounds.size.height + UIApplication.sharedApplication().statusBarFrame.size.height, width: self.view.bounds.size.width * 0.3, height: self.view.bounds.size.height * 0.05), font: UIFont(name: "Geomanist-Regular", size: 20.0)!, text: getFormattedDate(fiveDayStockData, index: 0))
        self.stockPriceLabel = createLabels(CGRect(x: 0, y: self.dateLabel.frame.origin.y + self.dateLabel.bounds.size.height, width: self.view.bounds.size.width * 0.45, height: self.view.bounds.size.height * 0.075), font: UIFont(name: "BebasNeueRegular", size: 40.0)!, text: "$" + (fiveDayStockData[0] as! Dictionary<String, String>)["Value"]!)
        
        self.graphView = BEMSimpleLineGraphView(frame: CGRect(x: 0, y: self.stockPriceLabel.frame.origin.y + self.stockPriceLabel.bounds.size.height, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.45))
        self.graphView.dataSource = self
        self.graphView.delegate = self
        self.graphView.dataValues = fiveDayStockData
        self.graphView.enablePopUpReport = true
        self.graphView.enableTouchReport = true
        
        let maxGraphDurationSpanOptionList = UISegmentedControl(items: ["5D", "1M", "3M", "6M", "1Y", "5Y"])
        maxGraphDurationSpanOptionList.frame = CGRect(x: 0, y: self.graphView.frame.origin.y + self.graphView.bounds.size.height + 1, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.05)
        maxGraphDurationSpanOptionList.selectedSegmentIndex = 0
        maxGraphDurationSpanOptionList.addTarget(self, action: #selector(changeGraph(_:)), forControlEvents: .ValueChanged)
        
        self.view.addSubview(self.graphView)
        self.view.addSubview(maxGraphDurationSpanOptionList)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func changeGraph(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getStockDataWithTimeLapse(.Day, duration: -5, databaseEntry: "fiveDayStockData", completion: { data in
                self.setDataAndReloadGraph(data)
            })
        } else if sender.selectedSegmentIndex == 1 {
            getStockDataWithTimeLapse(.Month, duration: -1, databaseEntry: "oneMonthStockData", completion: { data in
                self.setDataAndReloadGraph(data)
            })
        } else if sender.selectedSegmentIndex == 2 {
            getStockDataWithTimeLapse(.Month, duration: -3, databaseEntry: "threeMonthStockData", completion: { data in
                self.setDataAndReloadGraph(data)
            })
        } else if sender.selectedSegmentIndex == 3 {
            getStockDataWithTimeLapse(.Month, duration: -6, databaseEntry: "sixMonthStockData", completion: { data in
                self.setDataAndReloadGraph(data)
            })
        } else if sender.selectedSegmentIndex == 4 {
            getStockDataWithTimeLapse(.Year, duration: -1, databaseEntry: "oneYearStockData", completion: { data in
                self.setDataAndReloadGraph(data)
            })
        } else if sender.selectedSegmentIndex == 5 {
            getStockDataWithTimeLapse(.Year, duration: -5, databaseEntry: "fiveYearStockData", completion: { data in
                self.setDataAndReloadGraph(data)
            })
        }
    }
    
    func setDataAndReloadGraph(data: NSMutableArray){
        self.graphView.dataValues = data
        self.graphView.reloadGraph()
    }
    
    func getStockDataWithTimeLapse(calendarUnit: NSCalendarUnit, duration: Int, databaseEntry: String, completion: (data: NSMutableArray) -> Void){
        let calendar = NSCalendar.currentCalendar()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var latestStockDate = NSDate()
        while calendar.isDateInWeekend(latestStockDate) {
            latestStockDate = calendar.dateByAddingUnit(.Day, value: -1, toDate: latestStockDate, options: [])!
        }
        let endDate = dateFormatter.stringFromDate(latestStockDate)
        let startDate = dateFormatter.stringFromDate(calendar.dateByAddingUnit(calendarUnit, value: duration, toDate: latestStockDate, options: [])!)
        
        Constants.firebaseRef.child("listOfCompanyNamesAndCodes/\(stockCode)/data/\(databaseEntry)").observeSingleEventOfType(.Value, withBlock:  { snapshot in
            if !snapshot.exists() {
                let url = NSURL(string: "https://www.quandl.com/api/v3/datasets/WIKI/" + self.stockCode + ".json?api_key=sk7mgFNuMAy9JxMi5r-f&start_date=\(startDate)&end_date=\(endDate)")
                let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                        let stockData = (json["dataset"]!!["data"] as! Array<NSArray>).reverse()
                        
                        let stockDataForTimeLapse = NSMutableArray()
                        for dayStockData in stockData {
                            stockDataForTimeLapse.addObject(["Date": String(dayStockData[0]), "Value": String(dayStockData[1])])
                        }
                        dispatch_async(dispatch_get_main_queue()) {
                            /* Add the timelapse data graph into the DB */
                            Constants.firebaseRef.child("listOfCompanyNamesAndCodes/\(self.stockCode)/data/\(databaseEntry)").setValue(stockDataForTimeLapse)
                            completion(data: stockDataForTimeLapse)
                        }
                    } catch {
                        print("error serializing JSON: \(error)")
                    }
                }
                task.resume()
            } else {
                completion(data: snapshot.value as! NSMutableArray)
            }
        })
    }
    
    func createLabels(customFrame: CGRect, font: UIFont, text: String) -> UILabel {
        let label = UILabel(frame: customFrame)
        label.center.x = self.view.center.x
        label.textAlignment = .Center
        label.font = font
        label.text = text
        label.adjustsFontSizeToFitWidth = true
        self.view.addSubview(label)
        
        return label
    }
    
    func getFormattedDate(dataItem: NSMutableArray, index: Int) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.dateFromString((dataItem[index] as! Dictionary<String, String>)["Date"]!)
        dateFormatter.dateFormat = "d MMMM yyyy"
        
        return dateFormatter.stringFromDate(date!)
    }
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return graph.dataValues.count
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        let dictionaryItem = graph.dataValues[index]
        return CGFloat(NSNumberFormatter().numberFromString(dictionaryItem["Value"] as! String)!)
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: Int) {
        self.stockPriceLabel.text = "$" + (graph.dataValues[index] as! Dictionary<String, String>)["Value"]!
        self.dateLabel.text = getFormattedDate(graph.dataValues, index: index)
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
