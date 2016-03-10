//
//  User.swift
//  tetherUSv3
//
//  Created by Scott on 3/4/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import Foundation
import Firebase

protocol UserDelegate {
    func endUserInfoUpdate()
}

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
    var delegate:UserDelegate?
    
    // MARK: init functions
    
    init(authData: FAuthData) {
        
        self.uid = authData.uid
        
        let initGroup1 = dispatch_group_create()
        dispatch_group_enter(initGroup1)
        
        initialize() {
            dispatch_group_leave(initGroup1)
        }
        
        dispatch_group_notify(initGroup1, Utils.GlobalMainQueue){
            print("initGroup1")
            self.email = authData.providerData["email"] as? String
            self.image = authData.providerData["profileImageURL"] as? String
            self.isTethered = false
            self.isOnline = false
            
            self.delegate?.endUserInfoUpdate()
        }
    }
    
    init(uid: String) {
        
        self.uid = uid
        
        let initGroup2 = dispatch_group_create()
        dispatch_group_enter(initGroup2)
        
        initialize() {
            dispatch_group_leave(initGroup2)
        }
        
        dispatch_group_notify(initGroup2, Utils.GlobalMainQueue){
            print("initGroup2")
            self.delegate?.endUserInfoUpdate()
        }
    }
    
    init(uid: String, callback: (newUser:User) -> ()) {
        self.uid = uid
        
        let initGroup4 = dispatch_group_create()
        dispatch_group_enter(initGroup4)
        
        initialize(){
            dispatch_group_leave(initGroup4)
        }
        
        dispatch_group_notify(initGroup4, Utils.GlobalMainQueue){
            print("initGroup4")
            callback(newUser: self)
        }
    }
    
    func initialize(callback: () -> ()) {
        
        let initGroup3 = dispatch_group_create()
        dispatch_group_enter(initGroup3)
        
        if let userRef = usersRef.childByAppendingPath(uid) {
            userRef.onDisconnectUpdateChildValues(["isOnline" : false])
            
            userRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
                
                if let email = snapshot.value.objectForKey("email") {
                    self.email = email as? String
                }
                
                if let image = snapshot.value.objectForKey("image") {
                    self.image = image as? String
                }
                
                if let latitude = snapshot.value.objectForKey("latitude") {
                    self.latitude = latitude as? Double
                }
                
                if let longitude = snapshot.value.objectForKey("longitude") {
                    self.longitude = longitude as? Double
                }
                
                if let messages = snapshot.value.objectForKey("messages") {
                    self.messages = messages as? [String]
                }
                
                if let friends = snapshot.value.objectForKey("friends") {
                    self.friends = friends as? [String]
                }
                
                if let friendRequests = snapshot.value.objectForKey("friendRequests") {
                    
                    self.friendRequests = friendRequests as? [String]
                }
                
                if let tetherRequests = snapshot.value.objectForKey("tetherRequests") {
                    self.tetherRequests = tetherRequests as? [String]
                }
                
                dispatch_group_leave(initGroup3)
            })
        }
        
        dispatch_group_notify(initGroup3, Utils.GlobalMainQueue) {
            callback()
        }
    }
    
    // MARK: output functions
    
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
    
    // MARK: write functions
    
    func Save() {
        if let userRef = self.usersRef.childByAppendingPath(self.uid) {
            userRef.updateChildValues(self.ToDictionary())
            self.Refresh()
        }
    }
    
    // MARK: refresh
    
    func Refresh() {
        self.initialize(){}
    }
}

