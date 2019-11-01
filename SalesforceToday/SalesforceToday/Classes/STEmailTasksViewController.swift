//
//  STEmailTasksViewController.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import UIKit

class STEmailTasksViewController: UITableViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        
        if(STTaskStorage.getSFTasks() != nil) {
            allTasks = STTaskStorage.getSFTasks()!
        }
        
        if (allTasks.count > 0) {
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
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "Email Tasks"
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
        var cell = tableView.dequeueReusableCell(withIdentifier: STEmailTaskTableViewCellId) as! STTaskListCell
        let task = self.emailTasks[indexPath.row]
        cell.dueDate.text = task.object(forKey: "ActivityDate") as? String
        cell.priority.text = task.object(forKey: "Priority") as? String
        cell.subject.text = task.object(forKey: "Subject") as? String
        cell.status.text = task.object(forKey: "Status") as? String
        cell.backgroundColor = UIColor.white
        return cell
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Launch the main app.
        tableView.deselectRow(at: indexPath, animated: true)
        var task = self.emailTasks[indexPath.row]
        var taskID = task.object(forKey: "Id") as! String
        print(taskID)
        var url = NSURL(string:"salesforce1://sObject/\(taskID)/view")
        UIApplication.shared.openURL(url! as URL)
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var  headerCell = tableView.dequeueReusableCell(withIdentifier: "EmailSectionHeader") as! UITableViewCell
        
        return headerCell
    }

}
