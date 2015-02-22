//
//  LoginViewController.swift
//  Compass
//
//  Created by Mark on 2/22/15.
//  Copyright (c) 2015 MEB. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBOutlet var signupTriangle: UIImageView!
    @IBOutlet var loginTriangle: UIImageView!
    
    @IBOutlet var arrowButton: UIButton!
    
    // MARK: Variables
    var signUpActive = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    // MARK: View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set delegates
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // setup ui
        loginTriangle.alpha = 0
        arrowButton.userInteractionEnabled = false
        arrowButton.alpha = 0
        self.makeUsernameBorder()
        self.makePasswordBorder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool)
    {
        // hide nar bar
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        // show nav bar
        self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: Actions
    
    @IBAction func signupButtonToggled(sender: AnyObject) {
        if (signUpActive == false) {
            // disable signup mode
            signUpActive = true
            
            // change ui
            signupTriangle.alpha = 1
            loginTriangle.alpha = 0
        }
    }
    
    @IBAction func loginButtonToggled(sender: AnyObject) {
        if (signUpActive == true) {
            // disable signup mode
            signUpActive = false
            
            // change ui
            signupTriangle.alpha = 0
            loginTriangle.alpha = 1
        }
    }
    
    @IBAction func arrowButtonSelected(sender: AnyObject) {
        
    }
    
    @IBAction func facebookButtonSelected(sender: AnyObject) {
    }
    
    // MARK: Utility Methods
    
    func makeUsernameBorder() {
        var eborder = CALayer()
        var width = CGFloat(0.3)
        eborder.borderColor = UIColor.lightGrayColor().CGColor
        eborder.frame = CGRect(x: 0, y: usernameTextField.frame.size.height - width, width:  usernameTextField.frame.size.width, height: usernameTextField.frame.size.height)
        eborder.borderWidth = width
        usernameTextField.layer.addSublayer(eborder)
    }
    
    func makePasswordBorder() {
        var pborder = CALayer()
        var width = CGFloat(0.3)
        pborder.borderColor = UIColor.lightGrayColor().CGColor
        pborder.frame = CGRect(x: 0, y: passwordTextField.frame.size.height - width, width:  passwordTextField.frame.size.width, height: passwordTextField.frame.size.height)
        pborder.borderWidth = width
        passwordTextField.layer.addSublayer(pborder)
    }
    
    // MARK: Text Field Functions
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        // end editing when touching view
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // show buttons
        arrowButton.userInteractionEnabled = true
        arrowButton.alpha = 1
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        // hide buttons
        arrowButton.userInteractionEnabled = false
        arrowButton.alpha = 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
    }
    
    // MARK: Alert Functions
    
    func displayAlert(title:String, error:String) {
        // display error alert
        var errortAlert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        errortAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            // close alert
        }))
        
        self.presentViewController(errortAlert, animated: true, completion: nil)
    }
}
