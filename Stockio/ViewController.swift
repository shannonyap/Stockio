//
//  ViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/9/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBAction func signOut(sender: AnyObject) {
        GIDSignIn.sharedInstance().signOut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        
        let fbButton = UIButton(frame: CGRect(x: self.view.bounds.size.width / 2 - self.view.bounds.size.width * 0.25, y: self.view.bounds.size.height * 0.15, width: self.view.bounds.size.width * 0.5, height: self.view.bounds.size.height * 0.08))
        fbButton.setImage(UIImage(named: "Images/facebookLogin.png"), forState: UIControlState.Normal)
        fbButton.addTarget(self, action: #selector(btnFBLoginPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(fbButton)
        
        let googleButton = UIButton(frame: CGRect(x: self.view.bounds.size.width / 2 - self.view.bounds.size.width * 0.25, y: self.view.bounds.size.height / 2, width: self.view.bounds.size.width * 0.5, height: self.view.bounds.size.height * 0.08))
        googleButton.setImage(UIImage(named: "Images/googleSignIn.png"), forState: UIControlState.Normal)
        googleButton.addTarget(self, action: #selector(btnSignInPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(googleButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func btnFBLoginPressed(sender: AnyObject) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager .logInWithReadPermissions(["email"], handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    fbLoginManager.logOut()
                }
            }
        })
    }
    
    func getFBUserData(){
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    print(result)
                }
            })
        }
    }
    
    
    func btnSignInPressed() {
        GIDSignIn.sharedInstance().signIn()
    }

    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
                return
            }
            
            print("User logged in with google")
                  //  self.presentViewController(ViewController(), animated: true, completion: nil)
        })
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        try! FIRAuth.auth()!.signOut()
    }

}

