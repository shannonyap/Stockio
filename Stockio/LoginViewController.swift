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

extension UIViewController {
    func addTapGesture() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func isTapped (sender: UIButton) {
        sender.alpha = 0.7
    }
    
    func isTappedEnd (sender: UIButton) {
        sender.alpha = 1.0
        if sender.titleLabel?.text == "SIGN UP" {
            performSegueWithIdentifier("signUpSegue", sender: nil)
        } 
    }
    
}

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var emailTextField: UITextField = UITextField()
    var passwordTextField: UITextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        addTapGesture()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        let stockioBackground = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height * 0.4))
        stockioBackground.backgroundColor = UIColor(red: 58/255.0, green: 137/255.0, blue: 255/255.0, alpha: 1.0)

        createTopSegment(stockioBackground)

        self.emailTextField = FloatLabelTextField(frame: CGRect(x: stockioBackground.bounds.size.width * 0.15, y: stockioBackground.bounds.size.height * 1.05, width: stockioBackground.bounds.size.width * 0.7, height: stockioBackground.bounds.size.height * 0.17))
        self.emailTextField.placeholder = "Email"
        self.emailTextField.font = UIFont(name: "Geomanist-Regular", size: 16.0)
        self.emailTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
        
        let emailBorder = createTextFieldBorders(CGRect(x:  self.emailTextField.frame.origin.x, y: self.emailTextField.frame.origin.y +  self.emailTextField.bounds.size.height * 1.1, width:  self.emailTextField.bounds.size.width, height: 0.75))
        
        self.passwordTextField = FloatLabelTextField(frame: CGRect(x: stockioBackground.bounds.size.width * 0.15, y: stockioBackground.bounds.size.height * 1.275, width: self.emailTextField.bounds.size.width, height: self.emailTextField.bounds.size.height))
        self.passwordTextField.placeholder = "Password"
        self.passwordTextField.font = self.emailTextField.font
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
        
        let passwordBorder = createTextFieldBorders(CGRect(x: self.passwordTextField.frame.origin.x, y: self.passwordTextField.frame.origin.y + self.passwordTextField.bounds.size.height * 1.1, width: self.passwordTextField.bounds.size.width, height: 0.75))
        
        let signInButton = createButtons(CGRect(x: emailTextField.frame.origin.x, y: stockioBackground.bounds.size.height * 1.6, width: emailTextField.bounds.size.width, height: self.view.bounds.size.height * 0.065), title: "Sign In", titleColor: UIColor.whiteColor(), backgroundColor: UIColor(red: 58/255.0, green: 137/255.0, blue: 255/255.0, alpha: 1.0))
        
        let fbButton = createSignInButtons(CGRect(x: signInButton.frame.origin.x - signInButton.bounds.size.width * 0.02, y: stockioBackground.bounds.size.height * 1.8, width: signInButton.bounds.size.width * 1.04, height: signInButton.bounds.size.height), buttonImage: UIImage(named: "Images/facebookLogin.png")!, buttonType: "facebook")
        
        let googleButton = createSignInButtons(CGRect(x: signInButton.frame.origin.x - signInButton.bounds.size.width * 0.02, y: stockioBackground.bounds.size.height * 2, width: signInButton.bounds.size.width * 1.04, height: signInButton.bounds.size.height), buttonImage: UIImage(named: "Images/googleSignIn.png")!, buttonType: "google")
        
        let registrationLabel = UILabel(frame: CGRect(x: emailTextField.frame.origin.x + emailTextField.bounds.size.width * 0.1, y: stockioBackground.bounds.size.height * 2.275, width: emailTextField.bounds.size.width * 0.5, height: self.view.bounds.size.height * 0.035))
        registrationLabel.text = "NEW TO STOCKIO?"
        registrationLabel.font = UIFont(name: "Aileron-Light", size: 12.0)
        
        let registrationButton = createButtons(CGRect(x: registrationLabel.frame.origin.x + registrationLabel.bounds.size.width, y: registrationLabel.frame.origin.y, width: registrationLabel.bounds.size.width * 0.7, height: self.view.bounds.size.height * 0.035), title: "SIGN UP", titleColor: UIColor.blackColor(), backgroundColor: UIColor.clearColor())
    
        
        self.view.addSubview(stockioBackground)
        self.view.addSubview(self.emailTextField)
        self.view.addSubview(self.passwordTextField)
        self.view.addSubview(emailBorder)
        self.view.addSubview(passwordBorder)
        self.view.addSubview(registrationLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createButtons(customFrame: CGRect, title: String, titleColor: UIColor, backgroundColor: UIColor) -> UIButton {
        let button = UIButton(frame: customFrame)
        button.setTitle(title, forState: UIControlState.Normal)
        button.setTitleColor(titleColor, forState: UIControlState.Normal)
        button.backgroundColor = backgroundColor
        button.titleLabel!.font = UIFont(name: "Aileron-Regular", size: customFrame.size.height * 0.45)!
        if title == "SIGN UP" {
            button.titleLabel!.font = UIFont(name: "Aileron-Regular", size: 12.0)!
        }
        button.addTarget(self, action: #selector(isTapped(_:)), forControlEvents: .TouchDown)
        button.addTarget(self, action: #selector(isTappedEnd(_:)), forControlEvents: .TouchUpInside)
        self.view.addSubview(button)
        
        return button
    }
    
    func textFieldDidChange(textField: UITextField) {
        // Adding a pulse whenever the user clicks on the textField
        let pulsator = Pulsator()
        pulsator.frame = CGRect(x: textField.frame.origin.x, y: textField.frame.origin.y + textField.bounds.size.height / 1.25, width: 0, height: 0)
        pulsator.radius = textField.bounds.size.height / 2
        pulsator.numPulse = 1
        pulsator.animationDuration = 0.5525
        pulsator.repeatCount = 0
        self.view.layer.addSublayer(pulsator)
        pulsator.start()
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
