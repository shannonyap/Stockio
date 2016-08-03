//
//  StockContentViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 8/1/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class StockContentViewController: UIViewController, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {

    var stockName: String!
    var fiveDayStockData: NSMutableArray = NSMutableArray()
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.topItem?.title = stockName
        
        print(stockName)
        print(fiveDayStockData)
        
        let graphView = BEMSimpleLineGraphView(frame: CGRect(x: 0, y: navBar.bounds.size.height + UIApplication.sharedApplication().statusBarFrame.size.height, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.45))
        graphView.dataSource = self
        graphView.delegate = self
        graphView.dataValues = fiveDayStockData
        graphView.enablePopUpReport = true
        
        self.view.addSubview(graphView)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfPointsInLineGraph(graph: BEMSimpleLineGraphView) -> Int {
        return graph.dataValues.count
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
