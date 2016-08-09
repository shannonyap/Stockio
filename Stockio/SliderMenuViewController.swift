//
//  TableZTableViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/18/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class SliderMenuViewController: UITableViewController {
    
    var uid: String = ""
    let slideMenuTabs: Array = ["Watchlist", "Major Indices", "Mutual Funds", "Sign Out"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .None
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCellWithIdentifier("profileBar", forIndexPath: indexPath)
            var profPic = UIImageView(frame: CGRect(x: self.view.bounds.size.width * 0.30375, y: cell.bounds.size.height / 2 - self.view.bounds.size.width * 0.2025, width: self.view.bounds.size.width * 0.405, height: self.view.bounds.size.width * 0.405))
            profPic.layer.cornerRadius = profPic.bounds.size.height / 2
            cell.addSubview(profPic)
            
            let defaultUserImage = UIImageView(image: UIImage(named: "Images/user.png"))
            defaultUserImage.center = profPic.center
            defaultUserImage.bounds.size = CGSize(width: profPic.bounds.size.width * 0.5, height: profPic.bounds.size.height * 0.5)
            cell.addSubview(defaultUserImage)
            
            let shapeLayer = drawCircle(CGPoint(x: self.view.bounds.size.width * 0.51,y: cell.bounds.size.height / 2), radius: profPic.bounds.size.height / 2)
            cell.layer.addSublayer(shapeLayer)

            Constants.storageRef.child("users").child(uid).dataWithMaxSize(20 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print(error?.localizedDescription)
                } else {
                    profPic = UIImageView(image: UIImage(data: data!, scale: 1.0))
                    profPic.frame = CGRect(x: self.view.bounds.size.width * 0.3075, y: cell.bounds.size.height / 2 - self.view.bounds.size.width * 0.2025, width: self.view.bounds.size.width * 0.405, height: self.view.bounds.size.width * 0.405)
                    profPic.layer.cornerRadius = profPic.bounds.size.height / 2
                    profPic.layer.masksToBounds = true
                    cell.addSubview(profPic)
                }
            })
        } else {
            cell.textLabel?.font = UIFont(name: "EncodeSans-Light", size: 12.0)
            cell.textLabel?.text = slideMenuTabs[indexPath.row - 1]
            cell.bounds.size.height = 40.0
        }
        
        let customSeparator = UIView(frame: CGRect(x: 0, y: cell.bounds.size.height - 1, width: self.tableView.bounds.size.width, height: 0.5))
        customSeparator.backgroundColor = UIColor.grayColor()
        cell.addSubview(customSeparator)
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        return 40
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let title = self.evo_drawerController?.centerViewController?.childViewControllers.first?.navigationItem.title
        if indexPath.row == 1 {
            if title == "Watchlist" {
                self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
            } else {
                let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
                mainVC.initValues(uid, list: "listOfCompanyNamesAndCodes", dataSetName: "WIKI", watchlistName: "watchlist", financialType: "company", firebaseName: "companyName", firebaseCode: "companyCode")
                self.evo_drawerController?.setCenterViewController(UINavigationController(rootViewController: mainVC), withFullCloseAnimation: true, completion: nil)
            }
        } else if indexPath.row == 2 {
            if title == "Major Indices" {
                self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
            } else {
                self.evo_drawerController?.setCenterViewController(UINavigationController(rootViewController: UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("majorIndicesVC")), withFullCloseAnimation: true, completion: nil)
            }
        } else if indexPath.row == 3 {
            if title == "Mutual Funds" {
                self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: nil)
            } else {
                let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainVC") as! MainViewController
                mainVC.initValues(uid, list: "listOfMutualFunds", dataSetName: "", watchlistName: "Mutual Funds List", financialType: "Mutual Fund", firebaseName: "indexName", firebaseCode: "indexCode")
                self.evo_drawerController?.setCenterViewController(UINavigationController(rootViewController: mainVC), withFullCloseAnimation: true, completion: nil)
            }
        } else if indexPath.row == tableView.numberOfRowsInSection(0) - 1 {
            self.evo_drawerController?.toggleDrawerSide(.Left, animated: true, completion: { (true) in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        }
    }

    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        return true
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
