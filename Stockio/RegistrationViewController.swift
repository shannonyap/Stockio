//
//  RegistrationViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/11/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit
import Pulsator
import Firebase

class RegistrationViewController: UIViewController {
    
    var firstNameTextField = UITextField()
    var lastNameTextField = UITextField()
    var registrationEmailTextField = UITextField()
    var registrationPasswordTextField = UITextField()
    
    @IBAction func exitToLoginVC(sender: AnyObject) {
        (sender as! UIButton).alpha = 1.0
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func highlightCrossButton(sender: AnyObject) {
        (sender as! UIButton).alpha = 0.5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addTapGesture()
        createAddPhotoIcon()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let appLabel = UILabel(frame: CGRect(x: self.view.bounds.size.width * 0.5 - self.view.bounds.size.width * 0.66 / 2, y: self.view.bounds.size.height * 0.065, width: self.view.bounds.size.width * 0.66, height: self.view.bounds.size.height * 0.075))
        appLabel.text = "Stockio"
        appLabel.textAlignment = NSTextAlignment.Center
        appLabel.font = UIFont(name: "Geomanist-Regular", size: appLabel.bounds.size.height / 1.5)
        
        var float = FloatLabelTextField()
        
        float = createFloatTextField(float, customFrame: CGRect(x: self.view.bounds.size.width * 0.05, y: self.view.bounds.size.height * 0.5, width: self.view.bounds.size.width * 0.4, height: self.view.bounds.size.height * 0.07))
        self.firstNameTextField = float
        self.firstNameTextField = createCredentialTextField(self.firstNameTextField, placeholderText: "First Name", font: UIFont(name: "Geomanist-Regular", size: self.firstNameTextField.bounds.size.height * 0.45)!)
        createBorderLines(CGRect(x: self.firstNameTextField.frame.origin.x, y: self.firstNameTextField.frame.origin.y + self.firstNameTextField.bounds.size.height, width: self.firstNameTextField.bounds.size.width, height: 1.0))
        
        float = createFloatTextField(float, customFrame: CGRect(x: self.view.bounds.size.width * 0.55, y: self.firstNameTextField.frame.origin.y, width: self.firstNameTextField.bounds.size.width, height: self.firstNameTextField.bounds.size.height))
        self.lastNameTextField = float
        self.lastNameTextField = createCredentialTextField(self.lastNameTextField, placeholderText: "Last Name", font: self.firstNameTextField.font!)
        createBorderLines(CGRect(x: self.lastNameTextField.frame.origin.x, y: self.lastNameTextField.frame.origin.y + self.lastNameTextField.bounds.size.height, width: self.lastNameTextField.bounds.size.width, height: 1.0))
        
        float = createFloatTextField(float, customFrame: CGRect(x: self.firstNameTextField.frame.origin.x, y: self.view.bounds.size.height * 0.6, width: self.view.bounds.size.width - self.firstNameTextField.frame.origin.x * 2, height: self.firstNameTextField.bounds.size.height))
        self.registrationEmailTextField = float
        self.registrationEmailTextField = createCredentialTextField(self.registrationEmailTextField, placeholderText: "Email", font: self.firstNameTextField.font!)
        createBorderLines(CGRect(x: self.registrationEmailTextField.frame.origin.x, y: self.registrationEmailTextField.frame.origin.y + self.registrationEmailTextField.bounds.size.height, width: self.registrationEmailTextField.bounds.size.width, height: 1.0))
        
        float = createFloatTextField(float, customFrame: CGRect(x: self.firstNameTextField.frame.origin.x, y: self.view.bounds.size.height * 0.7, width: self.view.bounds.size.width - self.firstNameTextField.frame.origin.x * 2, height: self.firstNameTextField.bounds.size.height))
        self.registrationPasswordTextField = float
        self.registrationPasswordTextField = createCredentialTextField(self.registrationPasswordTextField, placeholderText: "Password", font: self.firstNameTextField.font!)
        self.registrationPasswordTextField.secureTextEntry = true
        createBorderLines(CGRect(x: self.registrationPasswordTextField.frame.origin.x, y: self.registrationPasswordTextField.frame.origin.y + self.registrationPasswordTextField.bounds.size.height, width: self.registrationPasswordTextField.bounds.size.width, height: 1.0))
        
        let registerButton = UIButton(frame: CGRect(x: self.view.bounds.size.width * 0.2, y: self.view.bounds.size.height * 0.835, width: self.view.bounds.size.width * 0.6, height: self.view.bounds.size.height * 0.055))
        registerButton.backgroundColor = UIColor.blackColor()
        registerButton.titleLabel!.font = UIFont(name: "Aileron-Regular", size: registerButton.bounds.size.height * 0.45)
        registerButton.setTitle("Register", forState: UIControlState.Normal)
        registerButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        registerButton.addTarget(self, action: #selector(isTapped(_:)), forControlEvents: UIControlEvents.TouchDown)
        registerButton.addTarget(self, action: #selector(createAccount(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(registerButton)
        
        self.view.addSubview(appLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func createAccount (sender: UIButton) {
        FIRAuth.auth()?.createUserWithEmail(self.registrationEmailTextField.text!, password: self.registrationPasswordTextField.text!, completion: { (user, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                print("The user id is \(user!.uid)")
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        })
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
    
    func createFloatTextField (floatTextField: FloatLabelTextField, customFrame: CGRect) -> FloatLabelTextField {
        let floatTextField = FloatLabelTextField(frame: customFrame)
        floatTextField.titleActiveTextColour = UIColor.blackColor()
        floatTextField.titleTextColour = floatTextField.titleActiveTextColour
        return floatTextField
    }
    
    func createCredentialTextField(textField: UITextField, placeholderText: String, font: UIFont) -> UITextField {
        textField.placeholder = placeholderText
        textField.font = font
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingDidBegin)
        self.view.addSubview(textField)
        
        return textField
    }
    
    func createBorderLines(customFrame: CGRect) {
        let borderLine = UIView(frame: customFrame)
        borderLine.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)
        self.view.addSubview(borderLine)
    }
    
    func createAddPhotoIcon() {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.view.bounds.size.width / 2,y: self.view.bounds.size.height / 3.75), radius: CGFloat(self.view.bounds.size.width / 6), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        //change the fill color
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        //you can change the stroke color
        shapeLayer.strokeColor = UIColor.blackColor().CGColor
        //you can change the line width
        shapeLayer.lineWidth = 2.0
        view.layer.addSublayer(shapeLayer)
        
        let cameraIcon = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width * 0.15, height: self.view.bounds.size.width * 0.15))
        cameraIcon.image = UIImage(contentsOfFile: NSBundle.mainBundle().pathForResource("camera", ofType: "png", inDirectory: "Images")!)
        cameraIcon.center = CGPoint(x: self.view.bounds.size.width / 2, y: self.view.bounds.size.height / 3.75)
        self.view.addSubview(cameraIcon)
        
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