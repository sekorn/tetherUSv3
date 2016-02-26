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
    var userSyncd: Bool = false
    
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
            
            userRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                if snapshot.exists() {
                    
                    if let latitude = snapshot.value.objectForKey("latitude") {
                        self.latitude = latitude as? Double
                    }
                    
                    if let longitude = snapshot.value.objectForKey("longitude") {
                        self.longitude = longitude as? Double
                    }
                    
                    if let friendRequests = snapshot.value.objectForKey("friendRequests") {
                        self.friendRequests = friendRequests as? [String]
                    }
                    
                    if let friends = snapshot.value.objectForKey("friends") {
                        self.friends = friends as? [String]
                    }
                    
                    if let tetherRequests = snapshot.value.objectForKey("tetherRequests") {
                        self.tetherRequests = tetherRequests as? [String]
                    }
                    
                    if let messages = snapshot.value.objectForKey("messages") {
                        self.messages = messages as? [String]
                    }
                    
                    self.userSyncd = true
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
            userRef.childByAppendingPath("friendRequests").observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                if snapshot.exists() {
                    var friendReqs = snapshot.value as! [String]
                    if !friendReqs.contains(self.uid) {
                        friendReqs.append(self.uid)
                        userRef.updateChildValues(["friendRequests": friendReqs])
                    }
                } else {
                    userRef.updateChildValues(["friendRequests": [self.uid]])
                }
            })
        }
    }
    
    func Save() {
        if let userRef = self.usersRef.childByAppendingPath(self.uid) {
            userRef.updateChildValues(self.ToDictionary())
        }
    }
    
    func updateFriendAlert() {
        
    }
}