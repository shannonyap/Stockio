//
//  SearchViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/22/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Firebase
import RAMReel

class SearchViewController: UIViewController, UICollectionViewDelegate {
    
    var dataSource: SimplePrefixQueryDataSource!
    var ramReel: RAMReel<RAMCell, RAMTextField, SimplePrefixQueryDataSource>!
    
    var listOfCompanyNames = [String]()
    
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
            
            self.ramReel = RAMReel(frame: self.view.bounds, dataSource: self.dataSource, placeholder: "Type in a company's name") {
                let result = $0
            }
            self.ramReel.hooks.append { _ in
                // do something with the data.
            }
            
            self.view.addSubview(self.ramReel.view)
            self.addCancelButton()
            self.ramReel.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        }
        
    }
    
    func addCancelButton() {
        let cancelButton = UIButton(frame: CGRect(x: self.view.bounds.size.width * 0.9, y: UIApplication.sharedApplication().statusBarFrame.size.height, width: self.view.bounds.size.width * 0.068, height: self.view.bounds.size.width * 0.068))
        cancelButton.setImage(UIImage(named: "crossIcons"), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: #selector(highlightCrossButton(_:)), forControlEvents: UIControlEvents.TouchDown)
        cancelButton.addTarget(self, action: #selector(exitToMainVC(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(cancelButton)
    }
    
    func exitToMainVC(sender: AnyObject) {
        (sender as! UIButton).alpha = 1.0
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func highlightCrossButton(sender: AnyObject) {
        (sender as! UIButton).alpha = 0.5
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
