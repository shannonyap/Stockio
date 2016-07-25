//
//  SearchViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/22/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import RAMReel

protocol searchViewControllerDataDelegate: class {
    func sendCompanyNameToMainVC(companyName: Dictionary<String, String>)
}

class SearchViewController: UIViewController, UICollectionViewDelegate {

    var delegate: searchViewControllerDataDelegate?
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    
    var setOfCompanyNames = Set<String>()
    var listOfCompanyNames = [String]()
    var selectedCompany: Dictionary<String, String> = [:]
    var addToWatchListButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        getAllCompanyNames { (companyNameList) in
            self.listOfCompanyNames = companyNameList
            self.dataSource = SimplePrefixQueryDataSource(self.listOfCompanyNames)
            
            for companyElem in self.listOfCompanyNames {
                self.setOfCompanyNames.insert(companyElem)
            }
            
            self.ramReel = RAMReel(frame: self.view.bounds, dataSource: self.dataSource, placeholder: "Type in a company's name") {
                let chosenCompany = $0
                if self.setOfCompanyNames.contains(chosenCompany) {
                    if !self.addToWatchListButton.isDescendantOfView(self.view) {
                        self.addToWatchListButton = self.addButton( CGRect(x: 0, y: self.view.bounds.size.height * 1.1, width: self.view.bounds.size.width * 0.6, height: self.view.bounds.size.height * 0.055), type: "addToWatchList")
                    }
                    UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations:  {
                        self.addToWatchListButton.frame.origin.y = self.view.bounds.size.height * 0.85 }, completion: nil)
                    Constants.firebaseRef.child("listOfCompanyNamesAndCodes").observeEventType(.ChildAdded, withBlock: { snapshot in
                        if snapshot.value!["companyName"] as! String == chosenCompany {
                            self.selectedCompany = ["companyName": snapshot.value!["companyName"] as! String, "companyCode": snapshot.value!["companyCode"] as! String]
                        }
                    })
                } else {
                    UIView.animateWithDuration(0.7, delay: 0, options: .CurveEaseInOut, animations:  {
                        self.addToWatchListButton.frame.origin.y = self.view.bounds.size.height * 1.1 }, completion: nil)
                    self.selectedCompany = [:]
                }
            }
            
            self.view.addSubview(self.ramReel.view)
            self.addButton(CGRect(x: self.view.bounds.size.width * 0.9, y: UIApplication.sharedApplication().statusBarFrame.size.height, width: self.view.bounds.size.width * 0.068, height: self.view.bounds.size.width * 0.068), type: "Image")
            self.ramReel.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        }
        
    }
    
    func addButton(customFrame: CGRect, type: String) -> UIButton {
        let button = UIButton(frame: customFrame)
        button.addTarget(self, action: #selector(highlightCrossButton(_:)), forControlEvents: UIControlEvents.TouchDown)
        button.addTarget(self, action: #selector(exitToMainVC(_:)), forControlEvents: (UIControlEvents.TouchUpInside))
        button.addTarget(self, action: #selector(exitToMainVC(_:)), forControlEvents: (UIControlEvents.TouchUpOutside))
        if type == "addToWatchList" {
            button.center.x = self.view.center.x
            button.setTitle("Add to Watchlist", forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont(name: "FjallaOne", size: 12.0)
            button.backgroundColor = UIColor.grayColor()
        } else {
            button.setImage(UIImage(named: "crossIcons"), forState: UIControlState.Normal)
        }
        self.view.addSubview(button)
        
        return button
    }
    
    func exitToMainVC(sender: UIButton) {
        sender.alpha = 1.0
        if !self.selectedCompany.isEmpty && sender.titleLabel?.text != nil {
            delegate?.sendCompanyNameToMainVC(self.selectedCompany)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func highlightCrossButton(sender: UIButton) {
        sender.alpha = 0.5
    }
    
    func getAllCompanyNames(completion: (companyNameList: [String]) -> Void) {
        var counter: UInt = 0
        Constants.firebaseRef.child("listOfCompanyNamesAndCodes").observeSingleEventOfType(.Value, withBlock: { snapshot in
            Constants.firebaseRef.child("listOfCompanyNamesAndCodes").observeEventType(.ChildAdded, withBlock: { realSnapshot in
                self.listOfCompanyNames.append(realSnapshot.value!["companyName"] as! String)
                counter += 1
                if counter == snapshot.childrenCount  {
                    completion(companyNameList: self.listOfCompanyNames)
                }
            })
        })
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
