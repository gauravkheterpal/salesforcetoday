//
//  STTaskStorage.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import Foundation


// It represents the App Group name.
let STAppSuiteName = "group.metacube.mobile.salesforcetoday"

// It represents the key for saving tasks in NSUserDefaults.
let STNSUserDefaultsTasksKey = "Tasks"

/*!
 This is the utility class to persist tasks and share among apps in the same app group.

 */
final class STTaskStorage {
    /*!
     Saves salesforce tasks.
     @param sftasks -> the salesforce tasks to save, nil will result the tasks to be removed
     @return true if saved successfully, false otherwise
     */
    class func saveSFTasks(sftasks : [NSDictionary]?) -> Bool {
        let sharedUserDefaults = NSUserDefaults(suiteName: STAppSuiteName)
        if (sftasks != nil) {
        
            var array = NSMutableArray()
            for task in sftasks! {
                array.addObject((NSKeyedArchiver.archivedDataWithRootObject(task)))
            }
            sharedUserDefaults!.setObject(array, forKey: STNSUserDefaultsTasksKey)
        } else {
            sharedUserDefaults!.removeObjectForKey(STNSUserDefaultsTasksKey)
        }
        return sharedUserDefaults!.synchronize()
    }
    
    /*!
     Get salesforce tasks.
     @return the salesforce tasks. nil if no tasks are present.
    */
    class func getSFTasks() -> [NSDictionary]? {
        let sharedUserDefaults = NSUserDefaults(suiteName: STAppSuiteName)
        if let array = sharedUserDefaults!.objectForKey(STNSUserDefaultsTasksKey) as? NSMutableArray {
            var sftasks : [NSDictionary] = []
            for data : AnyObject in array {
                sftasks.append(NSKeyedUnarchiver.unarchiveObjectWithData(data as! NSData) as! NSDictionary)
            }
            return sftasks
        } else {
            return nil
        }
    }
}