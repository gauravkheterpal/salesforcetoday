//
//  STTaskStorage.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import Foundation


// It represents the App Group name.
let STAppSuiteName = "group.com.metacube.mobile.salesforcetoday-app-mtx"

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
        let sharedUserDefaults = UserDefaults(suiteName: STAppSuiteName)
        if (sftasks != nil) {
        
            let array = NSMutableArray()
            for task in sftasks! {
                array.add((NSKeyedArchiver.archivedData(withRootObject: task)))
            }
            sharedUserDefaults!.set(array, forKey: STNSUserDefaultsTasksKey)
        } else {
            sharedUserDefaults!.removeObject(forKey: STNSUserDefaultsTasksKey)
        }
        return sharedUserDefaults!.synchronize()
    }
    
    /*!
     Get salesforce tasks.
     @return the salesforce tasks. nil if no tasks are present.
    */
    class func getSFTasks() -> [NSDictionary]? {
        let sharedUserDefaults = UserDefaults(suiteName: STAppSuiteName)
        if let array = sharedUserDefaults!.object(forKey: STNSUserDefaultsTasksKey) as? NSMutableArray {
            var sftasks : [NSDictionary] = []
            for data in array {
                guard let data = data as? Data else {continue}
                sftasks.append(NSKeyedUnarchiver.unarchiveObject(with: data) as! NSDictionary)
            }
            return sftasks
        } else {
            return nil
        }
    }
}
