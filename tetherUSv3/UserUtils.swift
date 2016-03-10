//
//  UserUtils.swift
//  tetherUSv3
//
//  Created by Scott on 3/8/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import Foundation

class UserUtils {
    
    static func AcceptFriend(user: User, friend: User) {
        // check that friend is not already in user.friends list
        
        if (((user.friends?.contains(friend.uid))) != nil) {
            return
        } else {
            // add friend.uid to user.friends list
            if user.friends == nil {
                user.friends = [friend.uid]
            } else {
                user.friends?.append(friend.uid)
            }
            
            // add user.uid to friends.friends list
            if friend.friends == nil {
                friend.friends = [user.uid]
            } else {
                friend.friends?.append(user.uid)
            }
            
            // remove friend.uid from user.request list
            var idx = 0
            for (index, value) in (user.friendRequests?.enumerate())! {
                if value == friend.uid {
                    idx = index
                    break
                }
            }
            user.friendRequests?.removeAtIndex(idx)
            
            // TODO:  update messages
            
            user.Save()
            friend.Save()
            
        }
    }
    
    static func RequestFriend(user: User, friend: User, callback: () -> ()) {
        // check that friend is not already in user.friendRequests or in user.friends Lists
        
        if ((friend.friends?.contains(user.uid)) != nil) || ((friend.friendRequests?.contains(user.uid)) != nil) {
            // if in either list
            return
        } else {
            // if not in either list
            if friend.friendRequests == nil {
                friend.friendRequests = [user.uid]
            } else {
                friend.friendRequests?.append(user.uid)
            }
            // TODO: update messages
            
            user.Save()
            friend.Save()
            
            callback()
        }
    }
}