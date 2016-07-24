//
//  MainViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/13/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import DrawerController

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        initVCWithNavBarPresets("Watchlist")
        addSearchBarButtonItem()
        
        self.tableView.tableFooterView = UIView()
        displayEmptyWatchListLabel()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayEmptyWatchListLabel() {
        let emptyWatchlist = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.3))
        emptyWatchlist.center = self.view.center
        emptyWatchlist.text = "Your Watchlist is empty"
        emptyWatchlist.textAlignment = .Center
        emptyWatchlist.font = UIFont(name: "BebasNeueLight", size: 30.0)
        self.view.addSubview(emptyWatchlist)
    }

    func addSearchBarButtonItem() {
        let barButton = UIBarButtonItem(image: UIImage(named: "searchIcon"), style: .Plain, target: self, action: #selector(didSelectSearchBarButtonItem(_:)))
        barButton.tintColor = UIColor.blackColor()
        self.navigationItem.setRightBarButtonItem(barButton, animated: true)
    }
    
    func didSelectSearchBarButtonItem(sender: UIBarButtonItem) {
        self.presentViewController(UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("searchVC"), animated: true, completion: nil)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "reuseIdentifier")
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
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
