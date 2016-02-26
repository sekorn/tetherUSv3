//
//  AddFriendViewController.swift
//  tetherUSv3
//
//  Created by Scott on 2/25/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import UIKit
import Firebase

class AddFriendViewController: UIViewController {

    var friendEmail:String?
    var friendId:String?
    var user: User?
    
    @IBOutlet weak var email: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.email.text = friendEmail
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        let usersRef = Firebase(url: FirebaseConstants.USERLIST)
        usersRef.observeAuthEventWithBlock { (authData) -> Void in
            if authData != nil {
                self.user = User(authData: authData)
            }
        }
    }
    @IBAction func RequestFriendButtonTapped(sender: AnyObject) {
        self.user!.RequestFriend(friendId!)
    }
    
    @IBAction func CancelButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
