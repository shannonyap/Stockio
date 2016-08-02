//
//  StockContentViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 8/1/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class StockContentViewController: UIViewController {

    var stockName: String!
    var fiveDayStockData: NSMutableArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(stockName)
        print(fiveDayStockData)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
