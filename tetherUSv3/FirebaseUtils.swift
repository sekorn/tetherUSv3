//
//  FirebaseUtils.swift
//  tetherUSv2
//
//  Created by Scott on 2/12/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import Foundation
import Firebase

struct FirebaseConstants {
    static let BASE: String = "https://tetherus.firebaseio.com/"
    static let USERLIST: String  = "https://tetherus.firebaseio.com/userlist"
    static let UNTETHERED: String = "https//tetherus.firebaseio.com/untetheredusers"
    static let TETHERLIST: String = "https://tetherus.firebaseio.com/tetherlist"
    static let TETHERCHAT: String = "https://tetherus.firebaseio.com/chat"
}

class FirebaseUtils {
    
    static func EmailSearch(search: String) {
        
        let query = search
        
        let usersRef = Firebase(url: FirebaseConstants.USERLIST)
        usersRef.queryOrderedByChild("email").queryEqualToValue(query).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            print(snapshot)
        })
    }
    
    static func UpdateFriendMessages(message: String, friendId: String) {
        
        let usersRef = Firebase(url: FirebaseConstants.USERLIST)
        
        if let userRef = usersRef.childByAppendingPath(friendId) {
            userRef.childByAppendingPath("messages").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                if snapshot.exists() {
                    var messages = usersRef.valueForKey("messages") as! [String]
                    messages.append(message)
                    usersRef.updateChildValues(["messages": messages])
                } else {
                    usersRef.updateChildValues(["messages": [message]])
                }
            })
        }
    }
    
    static func GetSearchExclusions(uid: String) -> [String] {
        var IDs = [String]()
        IDs.append(uid)
        
        let userRef = Firebase(url: FirebaseConstants.USERLIST).childByAppendingPath(uid)
        
        userRef.childByAppendingPath("friends").observeSingleEventOfType(.Value, withBlock: {(snapshot) -> Void in
            if snapshot.exists() {
                let friends = snapshot.value
                print(friends)
            }
        })
        
        return IDs
    }
}