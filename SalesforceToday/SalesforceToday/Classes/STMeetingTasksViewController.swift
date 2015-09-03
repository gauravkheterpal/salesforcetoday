//
//  STMeetingTasksViewController.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import UIKit

class STMeetingTasksViewController: UITableViewController {
   
    /*!
    This constant represents the table view cell ID in the storyboard.
    */
    let STMeetingTaskTableViewCellId = "meetingTaskCell"
    
    
    /*!
    This represents the tasks retrieved from Salesforce.
    */
    var meetingTasks : [NSDictionary] = []
    
    /*!
    This represents the tasks retrieved from Salesforce.
    */
    var allTasks : [NSDictionary] = []
    
    /*!
    This is called when the view is loaded.
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        allTasks = STTaskStorage.getSFTasks()!
        
        if (allTasks.count > 0) {
            for item in allTasks { // loop through all Tasks
                let obj = item as NSDictionary
                let type = obj.objectForKey("Type") as! String
                if type == "Meeting"
                {
                    meetingTasks.append(obj)
                }
            }
        }
        
        // Reload table data
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Meeting Tasks"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*!
    Returns the number of sections in the table view.
    @param tableView -> the table view
    @return the number of sections, always 1
    */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*!
    Returns the number of rows in a given section of a table view.
    @param tableView -> the table view
    @param section -> the section index
    @return the number of rows
    */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meetingTasks.count
    }
    
    /*!
    Returns a cell to insert in a particular location of the table view.
    @param tableView -> the table view
    @param indexPath -> the index path
    @return the cell
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(STMeetingTaskTableViewCellId) as! STTaskListCell
        let task = self.meetingTasks[indexPath.row]
        cell.dueDate.text = task.objectForKey("ActivityDate") as? String
        cell.priority.text = task.objectForKey("Priority") as? String
        cell.subject.text = task.objectForKey("Subject") as? String
        cell.status.text = task.objectForKey("Status") as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Launch the main app.
        
        var task = self.meetingTasks[indexPath.row]
        var taskID = task.objectForKey("Id") as! String
        print(taskID)
        var url = NSURL(string:"salesforce1://sObject/\(taskID)/view")
        UIApplication.sharedApplication().openURL(url!)
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var  headerCell = tableView.dequeueReusableCellWithIdentifier("MeetingSectionHeader") as! UITableViewCell
        
        return headerCell
    }
    
}
