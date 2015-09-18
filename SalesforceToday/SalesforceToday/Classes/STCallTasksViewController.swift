//
//  STCallTasksViewController.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

class STCallTasksViewController : UITableViewController, SFRestDelegate {
    /*!
    This constant represents the table view cell ID in the storyboard.
    */
    let STCallTaskTableViewCellId = "callTaskCell"
    
    /*!
    This represents the tasks retrieved from Salesforce.
    */
    var callTasks : [NSDictionary] = []
    var allTasks : [NSDictionary] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        // Send REST API request to Salesforce to query tasks of current user
        let request = SFRestAPI.sharedInstance().requestForQuery(
            "SELECT Id, Subject, Type, ActivityDate, Priority, Status FROM Task WHERE Status != 'Completed'"
                + " AND OwnerId = '\(SFUserAccountManager.sharedInstance().currentUserId)' ORDER BY ActivityDate")
        SFRestAPI.sharedInstance().send(request, delegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Call Tasks"
    }
    
    /*!
    This delegate is called when a request has finished loading.
    @param request -> the request
    @param jsonResponse -> the response
    */
    func request(request : SFRestRequest, didLoadResponse jsonResponse : AnyObject) {
        // Extract records
        var response = jsonResponse.objectForKey("records") as! [NSDictionary];

        for item in response { // loop through all Tasks
            let obj = item as NSDictionary
            
            if obj !=  NSNull() {
                
                if let type = obj["Type"] as? String {
                    
                    allTasks.append(obj)
                }
                
            }
        }
        

        if allTasks.isEmpty == false {
        
            //save tasks
            STTaskStorage.saveSFTasks(allTasks)
            for item in allTasks { // loop through all Tasks
                let obj = item as NSDictionary
                
                    if obj !=  NSNull() {
                    
                        if let type = obj["Type"] as? String {
                        
                            if type == "Call"
                            {
                                callTasks.append(obj)
                            }
                        }
                   
                }
            }
        }
        
        // Reload table data
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
            
        }
    }
    
    /*!
    This delegate is called when a request has failed due to an error.
    @param request -> the request
    @param error -> the error
    */
    func request(request : SFRestRequest, didFailLoadWithError error : NSError) {
        NSLog("STCallTasksViewController.request:didFailLoadWithError: REST API request failed: %@", error);
        
        SFAuthenticationManager.sharedManager().logout()
        
    }
    
    /*!
    This delegate is called when a request has be cancelled.
    @param request -> the request
    */
    func requestDidCancelLoad(request : SFRestRequest) {
        NSLog("STCallTasksViewController.requestDidCancelLoad: REST API request cancelled: %@", request);
        SFAuthenticationManager.sharedManager().logout()
        
    }
    
    /*!
    This delegate is called when a request has timed out.
    @param request -> the request
    */
    func requestDidTimeout(request : SFRestRequest) {
        NSLog("STCallTasksViewController.requestDidTimeout: REST API request timeout: %@", request);
        SFAuthenticationManager.sharedManager().logout()
        
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
        return callTasks.count
    }
    
    /*!
    Returns a cell to insert in a particular location of the table view.
    @param tableView -> the table view
    @param indexPath -> the index path
    @return the cell
    */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(STCallTaskTableViewCellId) as! STTaskListCell
        let task = self.callTasks[indexPath.row]
        cell.dueDate.text = task.objectForKey("ActivityDate") as? String
        cell.priority.text = task.objectForKey("Priority") as? String
        cell.subject.text = task.objectForKey("Subject") as? String
        cell.status.text = task.objectForKey("Status") as? String
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Launch the main app.
        
        var task = self.callTasks[indexPath.row]
        var taskID = task.objectForKey("Id") as! String
        print(taskID)
        var url = NSURL(string:"salesforce1://sObject/\(taskID)/view")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var  headerCell = tableView.dequeueReusableCellWithIdentifier("CallSectionHeader") as! UITableViewCell
        
        return headerCell
    }
    
}
