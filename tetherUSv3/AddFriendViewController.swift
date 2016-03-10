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

    var user: User?
    var friendId: String?
    var friend: User?
    
    @IBOutlet weak var email: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        dispatch_async(Utils.GlobalBackgroundQueue){
            User(uid: self.friendId!, callback: { (newUser) -> () in
                
                self.friend = newUser
                
                dispatch_async(Utils.GlobalMainQueue) {
                    self.email.text = self.friend!.email
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        
    }
    @IBAction func RequestFriendButtonTapped(sender: AnyObject) {
        UserUtils.RequestFriend(self.user!, friend: self.friend!) {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    @IBAction func CancelButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
}
