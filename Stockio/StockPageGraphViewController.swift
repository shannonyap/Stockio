//
//  StockGraphViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/31/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class StockGraphPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    var listOfStocks = []
    var currentStockIndexPath = -1
    var setOfGraphData = Array<NSMutableArray>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        let initialStockContentVC = getViewControllerAtIndex(currentStockIndexPath)
        let listOfViewControllers = NSArray(object: initialStockContentVC)
        self.setViewControllers(listOfViewControllers as? [UIViewController], direction: .Forward, animated: true, completion: nil)
        
        dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getViewControllerAtIndex (index: Int) -> StockContentViewController {
        let contentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("StockContentVC") as! StockContentViewController
        contentVC.stockName = listOfStocks[index].textLabel!!.text
        contentVC.fiveDayStockData = setOfGraphData[currentStockIndexPath]
        
        return contentVC
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        currentStockIndexPath = currentStockIndexPath + 1
        
        if currentStockIndexPath > listOfStocks.count - 1 {
            currentStockIndexPath = 0
        }
        
        let nextVC =  getViewControllerAtIndex(currentStockIndexPath)
        
        return nextVC
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        currentStockIndexPath = currentStockIndexPath - 1
        
        if currentStockIndexPath < 0 {
            currentStockIndexPath = listOfStocks.count - 1
        }
        
        let previousVC =  getViewControllerAtIndex(currentStockIndexPath)
        
        return previousVC
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
