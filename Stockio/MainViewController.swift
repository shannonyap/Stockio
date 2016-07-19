//
//  MainViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/13/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import DrawerController

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.whiteColor()
        
        let leftButton = DrawerBarButtonItem(target: self, action: #selector(leftDrawerButtonPress(_:)), menuIconColor: UIColor.blackColor())
        self.navigationItem.setLeftBarButtonItem(leftButton, animated: true)
        self.navigationController?.navigationBar.topItem!.title = "Watchlist"
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func leftDrawerButtonPress (sender: UIBarButtonItem) {
        self.evo_drawerController?.openDrawerSide(DrawerSide.Left, animated: true, completion: nil)
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
