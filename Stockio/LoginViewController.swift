//
//  LoginViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/9/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import Pulsator

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var emailTextField: UITextField = UITextField()
    var passwordTextField: UITextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let stockioBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.4))
        stockioBackground.backgroundColor = UIColor(red: 58/255.0, green: 137/255.0, blue: 255/255.0, alpha: 1.0)

        createTopSegment(stockioBackground)

        self.emailTextField = FloatLabelTextField(frame: CGRect(x: stockioBackground.bounds.size.width * 0.15, y: stockioBackground.bounds.size.height * 1.05, width: stockioBackground.bounds.size.width * 0.7, height: stockioBackground.bounds.size.height * 0.17))
        self.emailTextField.placeholder = "Email"
        self.emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Bottom
        self.emailTextField.font = UIFont(name: "Geomanist-Regular", size: 16.0)
        
        let emailBorder = createTextFieldBorders(CGRect(x:  self.emailTextField.frame.origin.x, y: self.emailTextField.frame.origin.y +  self.emailTextField.bounds.size.height * 1.1, width:  self.emailTextField.bounds.size.width, height: 0.75))
        
        self.passwordTextField = FloatLabelTextField(frame: CGRect(x: stockioBackground.bounds.size.width * 0.15, y: stockioBackground.bounds.size.height * 1.275, width: self.emailTextField.bounds.size.width, height: self.emailTextField.bounds.size.height))
        self.passwordTextField.placeholder = "Password"
        self.passwordTextField.font = self.emailTextField.font
        self.passwordTextField.contentVerticalAlignment = self.emailTextField.contentVerticalAlignment
        self.passwordTextField.secureTextEntry = true
        
        let passwordBorder = createTextFieldBorders(CGRect(x: self.passwordTextField.frame.origin.x, y: self.passwordTextField.frame.origin.y + self.passwordTextField.bounds.size.height * 1.1, width: self.passwordTextField.bounds.size.width, height: 0.75))
        
        let signInButton = UILabel(frame: CGRect(x: emailTextField.frame.origin.x, y: stockioBackground.bounds.size.height * 1.6, width: emailTextField.bounds.size.width, height: self.view.bounds.size.height * 0.065))
        signInButton.backgroundColor = UIColor(red: 58/255.0, green: 137/255.0, blue: 255/255.0, alpha: 1.0)
        signInButton.textColor = UIColor.whiteColor()
        signInButton.textAlignment = NSTextAlignment.Center
        signInButton.text = "Sign In"
        
        let fbButton = createSignInButtons(CGRect(x: signInButton.frame.origin.x - signInButton.bounds.size.width * 0.02, y: stockioBackground.bounds.size.height * 1.8, width: signInButton.bounds.size.width * 1.04, height: signInButton.bounds.size.height), buttonImage: UIImage(named: "Images/facebookLogin.png")!, buttonType: "facebook")
        
        let googleButton = createSignInButtons(CGRect(x: signInButton.frame.origin.x - signInButton.bounds.size.width * 0.02, y: stockioBackground.bounds.size.height * 2, width: signInButton.bounds.size.width * 1.04, height: signInButton.bounds.size.height), buttonImage: UIImage(named: "Images/googleSignIn.png")!, buttonType: "google")
        
        let registrationLabel = UILabel(frame: CGRect(x: emailTextField.frame.origin.x + emailTextField.bounds.size.width * 0.1, y: stockioBackground.bounds.size.height * 2.275, width: emailTextField.bounds.size.width * 0.5, height: self.view.bounds.size.height * 0.035))
        registrationLabel.text = "NEW TO STOCKIO?"
        registrationLabel.font = UIFont(name: "Aileron-Light", size: 12.0)
        
        let registrationButton = UIButton(frame: CGRect(x: registrationLabel.frame.origin.x + registrationLabel.bounds.size.width, y: registrationLabel.frame.origin.y, width: registrationLabel.bounds.size.width * 0.7, height: self.view.bounds.size.height * 0.035))
        registrationButton.setTitle("SIGN UP", forState: UIControlState.Normal)
        registrationButton.titleLabel!.font = UIFont(name: "Aileron-Regular", size: 12.0)!
        registrationButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        self.view.addSubview(stockioBackground)
        self.view.addSubview(self.emailTextField)
        self.view.addSubview(self.passwordTextField)
        self.view.addSubview(emailBorder)
        self.view.addSubview(passwordBorder)
        self.view.addSubview(signInButton)
        self.view.addSubview(registrationLabel)
        self.view.addSubview(registrationButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTopSegment(stockioBackground: UIView) {
        let stockioLabel = UILabel(frame: CGRect(x: (stockioBackground.bounds.size.width - stockioBackground.bounds.size.width * 0.3) / 2, y: stockioBackground.bounds.size.height * 0.15, width: stockioBackground.bounds.size.width * 0.3, height: stockioBackground.bounds.size.height * 0.15))
        stockioLabel.textAlignment = NSTextAlignment.Center
        stockioLabel.font = UIFont(name: "AvenirNext-Regular", size: 25.0)
        stockioLabel.text = "Stockio"
        stockioLabel.textColor = UIColor.whiteColor()
        
        let stockioCaption = UILabel(frame: CGRect(x: (stockioBackground.bounds.size.width - stockioBackground.bounds.size.width * 0.8) / 2, y: stockioBackground.bounds.size.height * 0.75, width: stockioBackground.bounds.size.width * 0.8, height: stockioBackground.bounds.size.height * 0.2))
        stockioCaption.textAlignment = NSTextAlignment.Center
        stockioCaption.text = "The Stock Market at your fingertips"
        stockioCaption.font = UIFont(name: "Aileron-Light", size: 15.0)
        stockioCaption.textColor = stockioLabel.textColor
        
        let stockioIcon = UIImageView(frame: CGRect(x: (self.view.bounds.size.width - self.view.bounds.size.width * 0.25) / 2, y: stockioBackground.bounds.size.height * 0.4, width: self.view.bounds.size.width * 0.25, height: self.view.bounds.size.width * 0.25))
        stockioIcon.image = UIImage(named: "Images/stockio.png")
        
        stockioBackground.self.addSubview(stockioLabel)
        stockioBackground.self.addSubview(stockioCaption)
        stockioBackground.self.addSubview(stockioIcon)
    }
    
    func createSignInButtons(customFrame: CGRect, buttonImage: UIImage, buttonType: String) {
        let button = UIButton(frame: customFrame)
        button.setImage(buttonImage, forState: UIControlState.Normal)
        button.imageView?.contentMode = .ScaleAspectFill
        if buttonType == "google" {
            button.addTarget(self, action: #selector(btnSignInPressed), forControlEvents: UIControlEvents.TouchUpInside)
        } else if buttonType == "facebook" {
            button.addTarget(self, action: #selector(btnFBLoginPressed), forControlEvents: UIControlEvents.TouchUpInside)
        }
        self.view.addSubview(button)
    }
    
    func createTextFieldBorders(customFrame: CGRect) -> UIView {
        let border = UIView(frame: customFrame)
        border.backgroundColor = UIColor(red: 236/255.0, green: 236/255.0, blue: 236/255.0, alpha: 1.0)
        return border
    }
    
    func firebaseSignIn(sender: AnyObject) {
        
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

