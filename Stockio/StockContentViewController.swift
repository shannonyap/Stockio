//
//  StockContentViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 8/1/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class StockContentViewController: UIViewController, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {

    var dateLabel = UILabel()
    var stockPriceLabel = UILabel()
    
    var stockName: String!
    var fiveDayStockData: NSMutableArray = NSMutableArray()
    var completeDates: Array<String> = Array<String>()
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.topItem?.title = stockName
        
        let dateFormatter = NSDateFormatter()
        for item in fiveDayStockData {
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.dateFromString((item as! Dictionary<String, String>)["Date"]!)
            dateFormatter.dateFormat = "d MMMM yyyy"
            completeDates.append(dateFormatter.stringFromDate(date!))
        }
        
        self.dateLabel = createLabels(CGRect(x: 0, y: navBar.bounds.size.height + UIApplication.sharedApplication().statusBarFrame.size.height, width: self.view.bounds.size.width * 0.3, height: self.view.bounds.size.height * 0.05), font: UIFont(name: "Geomanist-Regular", size: 20.0)!, text: completeDates[0])
        self.stockPriceLabel = createLabels(CGRect(x: 0, y: self.dateLabel.frame.origin.y + self.dateLabel.bounds.size.height, width: self.view.bounds.size.width * 0.45, height: self.view.bounds.size.height * 0.075), font: UIFont(name: "BebasNeueRegular", size: 40.0)!, text: "$" + (fiveDayStockData[0] as! Dictionary<String, String>)["Value"]!)
        
        let graphView = BEMSimpleLineGraphView(frame: CGRect(x: 0, y: self.stockPriceLabel.frame.origin.y + self.stockPriceLabel.bounds.size.height, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.45))
        graphView.dataSource = self
        graphView.delegate = self
        graphView.dataValues = fiveDayStockData
        graphView.enablePopUpReport = true
        graphView.enableTouchReport = true
        
        self.view.addSubview(graphView)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return graph.dataValues.count
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, valueForPointAtIndex index: Int) -> CGFloat {
        let dictionaryItem = graph.dataValues[index]
        return CGFloat(NSNumberFormatter().numberFromString(dictionaryItem["Value"] as! String)!)
    }
    
    func lineGraph(graph: BEMSimpleLineGraphView, didTouchGraphWithClosestIndex index: Int) {
        self.stockPriceLabel.text = "$" + (graph.dataValues[index] as! Dictionary<String, String>)["Value"]!
        self.dateLabel.text = completeDates[index]
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
