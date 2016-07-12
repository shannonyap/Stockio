//
//  RegistrationViewController.swift
//  Stockio
//
//  Created by Shannon Yap on 7/11/16.
//  Copyright © 2016 SYXH. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController {
    
    var firstNameTextField = UITextField()
    var lastNameTextField = UITextField()
    var registrationEmailTextField = UITextField()
    var registrationPasswordTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        createAddPhotoIcon()
        
        let appLabel = UILabel(frame: CGRect(x: self.view.bounds.size.width * 0.5 - self.view.bounds.size.width * 0.66 / 2, y: self.view.bounds.size.height * 0.065, width: self.view.bounds.size.width * 0.66, height: self.view.bounds.size.height * 0.075))
        appLabel.text = "Stockio"
        appLabel.textAlignment = NSTextAlignment.Center
        appLabel.font = UIFont(name: "Geomanist-Regular", size: appLabel.bounds.size.height / 1.5)
        
        var float = FloatLabelTextField()
        float = createFloatTextField(float, customFrame: CGRect(x: self.view.bounds.size.width * 0.05, y: self.view.bounds.size.height * 0.5, width: self.view.bounds.size.width * 0.4, height: self.view.bounds.size.height * 0.07))
        
        self.firstNameTextField = float
        self.firstNameTextField = createCredentialTextField(self.firstNameTextField, placeholderText: "First Name", font: UIFont(name: "Geomanist-Regular", size: self.firstNameTextField.bounds.size.height * 0.45)!)
        
        float = createFloatTextField(float, customFrame: CGRect(x: self.view.bounds.size.width * 0.55, y: self.firstNameTextField.frame.origin.y, width: self.firstNameTextField.bounds.size.width, height: self.firstNameTextField.bounds.size.height))
        self.lastNameTextField = float
        self.lastNameTextField = createCredentialTextField(self.lastNameTextField, placeholderText: "Last Name", font: self.firstNameTextField.font!)
        
        float = createFloatTextField(float, customFrame: CGRect(x: self.firstNameTextField.frame.origin.x, y: self.view.bounds.size.height * 0.6, width: self.view.bounds.size.width - self.firstNameTextField.frame.origin.x * 2, height: self.firstNameTextField.bounds.size.height))
        self.registrationEmailTextField = float
        self.registrationEmailTextField = createCredentialTextField(self.registrationEmailTextField, placeholderText: "Email", font: self.firstNameTextField.font!)
        
        float = createFloatTextField(float, customFrame: CGRect(x: self.firstNameTextField.frame.origin.x, y: self.view.bounds.size.height * 0.7, width: self.view.bounds.size.width - self.firstNameTextField.frame.origin.x * 2, height: self.firstNameTextField.bounds.size.height))
        self.registrationPasswordTextField = float
        self.registrationPasswordTextField = createCredentialTextField(self.registrationPasswordTextField, placeholderText: "Password", font: self.firstNameTextField.font!)
        self.registrationPasswordTextField.secureTextEntry = true
        
        self.view.addSubview(appLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.view.addSubview(textField)
        
        return textField
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
