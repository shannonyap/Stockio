//
//  SearchViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/22/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {
    
    var listOfCompanyNames = Set<String>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getAllCompanyNames { (companyNameList) in
            self.listOfCompanyNames = companyNameList
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAllCompanyNames(completion: (companyNameList: Set<String>) -> Void) {
        var counter: UInt = 0
        Constants.firebaseRef.child("listOfCompanyNamesAndCodes").observeSingleEventOfType(.Value, withBlock: { snapshot in
            Constants.firebaseRef.child("listOfCompanyNamesAndCodes").observeEventType(.ChildAdded, withBlock: { realSnapshot in
                self.listOfCompanyNames.insert(realSnapshot.value!["companyName"] as! String)
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
