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
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        // Send REST API request to Salesforce to query tasks of current user
        guard let userID = SFUserAccountManager.sharedInstance().currentUserId else { return }
        let request = SFRestAPI.sharedInstance().request(
            forQuery: "SELECT Id, Subject, ActivityDate, Priority, Status, Type FROM Task WHERE Status != 'Completed'"
                + " AND OwnerId = '\(userID)' ORDER BY ActivityDate")
        SFRestAPI.sharedInstance().send(request, delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Call Tasks"
    }
    
    /*!
    This delegate is called when a request has finished loading.
    @param request -> the request
    @param jsonResponse -> the response
    */
    func request(_ request: SFRestRequest!, didLoadResponse dataResponse: Any!) {
        if let response = dataResponse as? NSDictionary {
            var res = response.object(forKey: "records") as! [NSDictionary]
            
            for item in res { // loop through all Tasks
                let obj = item as NSDictionary
                
                if obj !=  NSNull() {
                    
                    if let type = obj["Type"] as? String {
                        
                        allTasks.append(obj)
                    }
                    
                }
            }
            
            
            if allTasks.isEmpty == false {
                
                //save tasks
                STTaskStorage.saveSFTasks(sftasks: allTasks)
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
        }
        
        // Reload table data
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    /*!
    This delegate is called when a request has failed due to an error.
    @param request -> the request
    @param error -> the error
    */
    func request(_ request: SFRestRequest!, didFailLoadWithError error: Error!) {
        print("STCallTasksViewController.request:didFailLoadWithError: REST API request failed:", error!)
        
        SFAuthenticationManager.shared().logout()
    }
    
    /*!
    This delegate is called when a request has be cancelled.
    @param request -> the request
    */
    func requestDidCancelLoad(_ request: SFRestRequest!) {
        print("STCallTasksViewController.requestDidCancelLoad: REST API request cancelled: ", request!)
        SFAuthenticationManager.shared().logout()
    }
    
    /*!
    This delegate is called when a request has timed out.
    @param request -> the request
    */
    func requestDidTimeout(_ request: SFRestRequest!) {
        print("STCallTasksViewController.requestDidTimeout: REST API request timeout: ", request!)
        SFAuthenticationManager.shared().logout()
    }
    
    /*!
    Returns the number of sections in the table view.
    @param tableView -> the table view
    @return the number of sections, always 1
    */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /*!
    Returns the number of rows in a given section of a table view.
    @param tableView -> the table view
    @param section -> the section index
    @return the number of rows
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return callTasks.count
    }
    
    /*!
    Returns a cell to insert in a particular location of the table view.
    @param tableView -> the table view
    @param indexPath -> the index path
    @return the cell
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: STCallTaskTableViewCellId) as! STTaskListCell
        let task = self.callTasks[indexPath.row]
        cell.dueDate.text = task.object(forKey: "ActivityDate") as? String
        cell.priority.text = task.object(forKey: "Priority") as? String
        cell.subject.text = task.object(forKey: "Subject") as? String
        cell.status.text = task.object(forKey: "Status") as? String
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Launch the main app.
        
        var task = self.callTasks[indexPath.row]
        var taskID = task.object(forKey: "Id") as! String
        print(taskID)
        var url = NSURL(string:"salesforce1://sObject/\(taskID)/view")
        UIApplication.shared.openURL(url! as URL)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var  headerCell = tableView.dequeueReusableCell(withIdentifier: "CallSectionHeader") as! UITableViewCell
        
        return headerCell
    }
}
