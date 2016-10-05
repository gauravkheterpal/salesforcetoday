//
//  STEmailTasksViewController.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import UIKit

class STEmailTasksViewController: UITableViewController, SFRestDelegate {

    /*!
    This constant represents the table view cell ID in the storyboard.
    */
    let STEmailTaskTableViewCellId = "emailTaskCell"
    
    /*!
    This represents the email tasks retrieved from Salesforce.
    */
    var emailTasks : [NSDictionary] = []
    
    /*!
    This represents the tasks retrieved from Salesforce.
    */
    var allTasks : [NSDictionary] = []
    
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)

    override func viewDidLoad() {
        super.viewDidLoad()
        indicator.color = UIColor .black
        indicator.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.bringSubview(toFront: self.view)

    }
    
    
    override func viewDidAppear(_ animated: Bool) {
         showTasks()
    }
    
    func showTasks() {
        emailTasks = []
        allTasks = []
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 44.0
        // Send REST API request to Salesforce to query tasks of current user
        let request = SFRestAPI.sharedInstance().request(
            forQuery: "SELECT Id, Subject, Type, ActivityDate, Priority, Status FROM Task WHERE Status != 'Completed'"
                + " AND OwnerId = '\(SFUserAccountManager.sharedInstance().currentUserId!)' ORDER BY ActivityDate limit 10")
        
        SFRestAPI.sharedInstance().send(request, delegate: self)
        indicator.startAnimating()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Email Tasks"
        let refreshButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.refresh, target: self, action: #selector(STEmailTasksViewController.showTasks))
        self.tabBarController?.navigationItem.leftBarButtonItem = refreshButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
/*!
     This delegate is called when a request has finished loading.
     @param request -> the request
     @param jsonResponse -> the response
     */
    func request(_ request : SFRestRequest, didLoadResponse jsonResponse : AnyObject) {
        // Extract records
        let response = jsonResponse.object(forKey: "records") as! [NSDictionary];
        
        for item in response { // loop through all Tasks
            let obj = item as NSDictionary
            
            if obj !=  NSNull() {
                
                if (obj["Type"] as? String) != nil {
                    
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
                        
                        if type == "Email"
                        {
                            emailTasks.append(obj)
                        }
                    }
                }
            }
        }
        
        // Reload table data
        DispatchQueue.main.async {
            self.indicator.stopAnimating()
            self.indicator.hidesWhenStopped = true
            self.tableView.reloadData()
            
        }
    }
    
    /*!
     This delegate is called when a request has failed due to an error.
     @param request -> the request
     @param error -> the error
     */
    func request(_ request : SFRestRequest, didFailLoadWithError error : NSError) {
        NSLog("STCallTasksViewController.request:didFailLoadWithError: REST API request failed: %@", error);
        
        SFAuthenticationManager.shared().logout()
        
    }
    
    /*!
     This delegate is called when a request has be cancelled.
     @param request -> the request
     */
    func requestDidCancelLoad(_ request : SFRestRequest) {
        NSLog("STCallTasksViewController.requestDidCancelLoad: REST API request cancelled: %@", request);
        SFAuthenticationManager.shared().logout()
    }
    
    /*!
     This delegate is called when a request has timed out.
     @param request -> the request
     */
    func requestDidTimeout(_ request : SFRestRequest) {
        NSLog("STCallTasksViewController.requestDidTimeout: REST API request timeout: %@", request);
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
        return emailTasks.count
    }
    
    /*!
    Returns a cell to insert in a particular location of the table view.
    @param tableView -> the table view
    @param indexPath -> the index path
    @return the cell
    */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: STEmailTaskTableViewCellId) as! STTaskListCell
        let task = self.emailTasks[(indexPath as NSIndexPath).row]
        cell.dueDate.text = task.object(forKey: "ActivityDate") as? String
        cell.priority.text = task.object(forKey: "Priority") as? String
        cell.subject.text = task.object(forKey: "Subject") as? String
        cell.status.text = task.object(forKey: "Status") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Launch the main app.
        
        let task = self.emailTasks[(indexPath as NSIndexPath).row]
        let taskID = task.object(forKey: "Id") as! String
        print(taskID, terminator: "")
        let url = URL(string:"salesforce1://sObject/\(taskID)/view")
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url!, options: [ : ], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  headerCell = tableView.dequeueReusableCell(withIdentifier: "EmailSectionHeader")
        
        return headerCell
    }
}
