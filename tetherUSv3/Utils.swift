//
//  Utils.swift
//  tetherUSv3
//
//  Created by Scott on 3/4/16.
//  Copyright © 2016 Scott Kornblatt. All rights reserved.
//

import Foundation

class Utils {
    
    static var GlobalMainQueue: dispatch_queue_t {
        return dispatch_get_main_queue()
    }
    
    static var GlobalUserInteractiveQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)
    }
    
    static var GlobalUserInitiatedQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.rawValue), 0)
    }
    
    static var GlobalUtilityQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)
    }
    
    static var GlobalBackgroundQueue: dispatch_queue_t {
        return dispatch_get_global_queue(Int(QOS_CLASS_BACKGROUND.rawValue), 0)
    }
}