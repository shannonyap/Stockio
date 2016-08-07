//
//  MajorIndicesViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 8/6/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class MajorIndicesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate {

    @IBOutlet weak var tableView: UITableView!
    var listOfIndices = Array<Dictionary<String, Dictionary<String, AnyObject>>>()
    var miniGraphData = Array<Dictionary<String, String>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTableViewDelegatePresets(self.tableView, tableViewDataSource: self, viewController: self, title: "Major Indices")
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        if self.listOfIndices.count == 0 {
            Constants.firebaseRef.child("listOfIndices").observeSingleEventOfType(.Value, withBlock: { snapshot in
                for index in snapshot.value as! Dictionary<String, Dictionary<String, AnyObject>> {
                    self.listOfIndices.append([index.0: index.1])
                }
                self.listOfIndices = self.listOfIndices.sort { first, second in
                    return first.keys.first < second.keys.first
                }
                self.tableView.reloadData()
            })
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let stockGraphVC = UIStoryboard(name: "Main", bundle:nil).instantiateViewControllerWithIdentifier("StockGraphVC") as! StockGraphPageViewController
        stockGraphVC.listOfStocks = tableView.visibleCells
        stockGraphVC.list = "listOfIndices"
        stockGraphVC.dataSetName = ""
        
        for cell in stockGraphVC.listOfStocks {
            if self.tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text == (cell as! StockDataTableViewCell).textLabel!.text! {
                stockGraphVC.currentStockIndexPath = stockGraphVC.listOfStocks.indexOfObject(cell)
            }
            let graph = cell.subviews.filter{$0 is BEMSimpleLineGraphView}.first as! BEMSimpleLineGraphView
            stockGraphVC.setOfGraphData.append(graph.dataValues)
            stockGraphVC.listOfCompanyNames.append((cell as! StockDataTableViewCell).companyName)
            stockGraphVC.listOfCompanyCodes.append((cell as! StockDataTableViewCell).indexCode)
            stockGraphVC.stockKeyCode.append((cell as! StockDataTableViewCell).textLabel!.text!)
        }
        
        self.presentViewController(stockGraphVC, animated: true, completion: nil)
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfIndices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = StockDataTableViewCell(style: .Default, reuseIdentifier: "reuseIdentifier")
        cell.textLabel?.text = self.listOfIndices[indexPath.row].keys.first
        cell.companyName = self.listOfIndices[indexPath.row][self.listOfIndices[indexPath.row].keys.first!]!["indexName"]! as! String
        cell.indexCode = self.listOfIndices[indexPath.row][self.listOfIndices[indexPath.row].keys.first!]!["indexCode"]! as! String
        cell.textLabel?.font = UIFont(name: "Genome-Thin", size: 17.5)

        let priceChangeLabel = createPriceChangeStatusLabel(CGRect(x: self.view.bounds.size.width * 0.95 - cell.bounds.size.width * 0.175, y: 0, width: cell.bounds.size.width * 0.175, height: cell.bounds.size.height * 0.7), font: UIFont(name: "BebasNeueLight", size: cell.bounds.size.height * 0.5)!, center: self.view.bounds.size.height * 0.05, cornerRadius: cell.bounds.size.height * 0.1, companyCode: self.listOfIndices[indexPath.row][self.listOfIndices[indexPath.row].keys.first!]!["indexCode"]! as! String, companyKeyCode: self.listOfIndices[indexPath.row].keys.first!, list: "listOfIndices", databaseName: "", miniGraphData: self.miniGraphData, completion: { priceChangeLabel, data in
            self.miniGraphData = data
            self.createMiniGraph(CGRect(x: 0, y: 0, width: cell.bounds.size.width * 0.3, height: self.view.bounds.size.height * 0.095),lineColor: priceChangeLabel.backgroundColor!, cell: cell, dataValues: self.miniGraphData, view: self.view, dataSource: self, delegate: self)
        })
 
        cell.addSubview(priceChangeLabel)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.bounds.size.height * 0.1
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
