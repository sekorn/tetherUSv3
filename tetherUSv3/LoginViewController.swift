//
//  LoginViewController.swift
//  tetherUSv2
//
//  Created by Scott on 2/4/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class LoginViewController: UIViewController {
    
    let LoginToHome = "LoginToHomeSegue"
    
    let firebase = Firebase(url: FirebaseConstants.BASE)
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        
        firebase.unauth()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        firebase.observeAuthEventWithBlock { (authData) -> Void in
            
            if authData != nil {
                self.performSegueWithIdentifier(self.LoginToHome, sender: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signupPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Register", message: "Register New User", preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action) -> Void in
            
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            
            self.firebase.createUser(emailField.text, password: passwordField.text, withCompletionBlock: { (error) -> Void in
                
                if error == nil {
                    self.firebase.authUser(emailField.text, password: passwordField.text, withCompletionBlock: { (error, authData) -> Void in
                        
                    })
                }
            })
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction) -> Void in
            
        }
        
        
        alert.addTextFieldWithConfigurationHandler { (textEmail) -> Void in
            textEmail.placeholder = "enter an email address"
        }
        
        alert.addTextFieldWithConfigurationHandler { (textPassword) -> Void in
            textPassword.placeholder = "enter a password"
            textPassword.secureTextEntry = true
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        firebase.authUser(emailTextField.text, password: passwordTextField.text) { (error, authData) -> Void in
            
        }
    }
}
