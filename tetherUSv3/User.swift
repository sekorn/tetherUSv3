//
//  User.swift
//  tetherUSv2
//
//  Created by Scott on 2/6/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    let usersRef = Firebase(url: FirebaseConstants.USERLIST)
    
    var uid: String
    var email: String?
    var image: String?
    var isTethered: Bool?
    var isOnline: Bool?
    var latitude: Double?
    var longitude: Double?
    var messages: [String]?
    var friends: [String]?
    var friendRequests: [String]?
    var tetherRequests: [String]?
    
    init(authData: FAuthData) {
        self.uid = authData.uid
        self.email = authData.providerData["email"] as? String
        self.image = authData.providerData["profileImageURL"] as? String
        self.isTethered = false
        self.isOnline = false
        
        initialize()
    }
    
    init(uid: String, email: String, image: String, isTethered: Bool, isOnline: Bool) {
        self.uid = uid
        self.email = email
        self.image = image
        self.isTethered = isTethered
        self.isOnline = isOnline
        
        initialize()
    }
    
    func initialize() {
        
        if let userRef = usersRef.childByAppendingPath(self.uid) {
            userRef.onDisconnectUpdateChildValues(["isOnline" : false])
            
            userRef.childByAppendingPath("friends").observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
                if snapshot.exists() {
                    self.friends = userRef.valueForKey("friends") as? [String]
                }
            })
            
            userRef.childByAppendingPath("friendRequests").observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
                if snapshot.exists() {
                    self.friendRequests = userRef.valueForKey("friendRequests") as? [String]
                }
            })
            
            userRef.childByAppendingPath("tetherRequests").observeSingleEventOfType(.Value, withBlock: {(snapshot)
                in
                if snapshot.exists() {
                    self.tetherRequests = userRef.valueForKey("tetherRequets") as? [String]
                }
            })
            
            userRef.childByAppendingPath("messages").observeSingleEventOfType(.Value, withBlock: {(snapshot)
                in
                if snapshot.exists() {
                    self.tetherRequests = userRef.valueForKey("messages") as? [String]
                }
            })
        }
    }
    
    func ToDictionary() -> Dictionary<NSObject, AnyObject> {
        var output = [NSObject: AnyObject]()
        
        output["email"] = self.email
        output["image"] = self.image
        output["isTethered"] = self.isTethered
        output["friends"] = self.friends
        output["friendRequests"] = self.friendRequests
        output["tetherRequests"] = self.tetherRequests
        output["isOnline"] = self.isOnline
        output["latitude"] = self.latitude
        output["longitude"] = self.longitude
        return output
    }
    
    func AcceptFriend(friendId: String) {
        
        if friends != nil {
            friends!.append(friendId)
        }
        
        var removeIndex = -1
        for (index, value) in friendRequests!.enumerate() {
            if value == friendId {
                removeIndex = index
                break
            }
        }
        
        if removeIndex != -1 {
            friendRequests!.removeAtIndex(removeIndex)
        }
        
        self.Save()
    }
    
    func RequestFriend(friendId: String) {
        if let userRef = self.usersRef.childByAppendingPath(friendId) {
            if let friendReqs = userRef.valueForKey("friendRequests") {
                friendReqs.appendString(self.uid)
                userRef.updateChildValues(["friendRequests": friendReqs])
            } else {
                userRef.updateChildValues(["friendRequets" : ["\(self.uid)"]])
            }
        }
    }
    
    func Save() {
        if let userRef = self.usersRef.childByAppendingPath(self.uid) {
            userRef.updateChildValues(self.ToDictionary())
        }
    }
}