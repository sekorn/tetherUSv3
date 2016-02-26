//
//  HomeViewController.swift
//  tetherUSv2
//
//  Created by Scott on 2/6/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

protocol HomeViewControllerDelegate {
    func updateFriendAlert()
}

class HomeViewController: UIViewController, CLLocationManagerDelegate {
    
    let seconds: Double = 5.0
    let locationManager = CLLocationManager()
    let HomeToFriends = "HomeToFriendListSegue"
    let untetheredRef = Firebase(url: FirebaseConstants.UNTETHERED)
    let usersRef = Firebase(url: FirebaseConstants.USERLIST)
    
    var canPing: Bool = false
    var user: User!
    var timer: NSTimer!
    
    var aiView: UIActivityIndicatorView?
    var overlayView: UIView?
    
    @IBOutlet weak var FriendAlert: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: Selector("SetTimerFlag:"), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        overlayView = UIView(frame: view.frame)
        overlayView!.center = view.center
        overlayView?.backgroundColor = UIColor.grayColor()
        overlayView?.alpha = 0.5
        
        aiView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        aiView!.center = (overlayView?.center)!
        aiView?.hidesWhenStopped = true
        overlayView?.addSubview(aiView!)
        
        view.addSubview(overlayView!)
        aiView?.startAnimating()
        
        usersRef.observeAuthEventWithBlock { (authData) -> Void in
            if authData != nil {
                self.user = User(authData: authData)
                self.user.isTethered = false
                self.user.isOnline = true
                
                self.user.Save()
            }
        }
    }
    
    @IBAction func TetherButtonPressed(sender: AnyObject) {
        self.performSegueWithIdentifier(HomeToFriends, sender: sender)
    }
    
    @IBAction func FriendAlertButtonPressed(sender: AnyObject) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == HomeToFriends {
            let vc = segue.destinationViewController as? FriendListTableViewController
            vc!.user = self.user
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.user != nil && canPing == true {
            let currentUserRef = self.usersRef.childByAppendingPath(self.user.uid)
            let coords = ["latitude": self.locationManager.location!.coordinate.latitude, "longitude" : self.locationManager.location!.coordinate.longitude]
            currentUserRef.updateChildValues(coords)
            canPing = false
        }
    }
    
    func SetTimerFlag(timer : NSTimer) {
        canPing = true
    }
}
