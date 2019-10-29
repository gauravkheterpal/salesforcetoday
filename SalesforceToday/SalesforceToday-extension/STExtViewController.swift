//
//  STExtViewController.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import UIKit
import NotificationCenter



// This is the UIViewController for showing the Salesforce tasks in Today view.


class STExtViewController: UITableViewController, NCWidgetProviding {
    
    // It represents the today view cell ID in the storyboard.
    
    let STExtTodayViewCellId = "todayViewCell"
    
    // It represents the message cell ID in the storyboard.
    
    let STExtMessageCellId = "messageCell"
    
    // It represents the maximum number of tasks to show in Today view.
    
    let STExtMaxTasksInTodayView = 5
    
    // It represents the task cell height.
    
    let STExtTaskCellHeight = 45
    
    // It represents the message cell height.
    
    let STExtMessageCellHeight = 32
    
    // It represents the tasks retrieved from Salesforce.
    
    var tasks : [NSDictionary]?
    
    //It represents the preferred view height determined based on its content.
    
    var preferredViewHeight : CGFloat {
        if tasks != nil && tasks!.isEmpty {
            
            return CGFloat(STExtMessageCellHeight)
            
        } else if tasks != nil && !tasks!.isEmpty {
            
            return CGFloat(STExtTaskCellHeight * tasks!.count)
            
        } else {
            
            return CGFloat(STExtMessageCellHeight)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.clear
        
        // Get tasks
        self.tasks = STTaskStorage.getSFTasks()
        // Set preferred height
        var preferredSize = preferredContentSize
        preferredSize.height = self.preferredViewHeight
        preferredContentSize = preferredSize
        
        // Reload data
        self.tableView.reloadData()
    }
    
    /*!
    This is called to give a widget an opportunity to update its contents.
    @param completionHandler -> the completion handler
    */
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(NCUpdateResult.newData)
    }
    
    /*!
    Returns the number of sections in the table view.
    @param tableView -> the table view
    @return the number of sections, always 1
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*!
    Returns the number of rows in a given section of a table view.
    @param tableView -> the table view
    @param section -> the section index
    @return the number of rows
    */
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasks != nil && !tasks!.isEmpty {
            return tasks!.count > STExtMaxTasksInTodayView ? STExtMaxTasksInTodayView : tasks!.count
        } else {
            return 1
        }
    }
    
    /*!
     Returns a cell to insert in a particular location of the table view.
     @param tableView -> the table view
     @param indexPath -> the index path
     @return the cell
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sharedUserDefaults = UserDefaults(suiteName: STAppSuiteName)
        if let authenticationStr = sharedUserDefaults!.object(forKey: "Authentication") as? NSString {
            
            if authenticationStr == "YES" && !(self.tasks != nil) {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: STExtMessageCellId) as! UITableViewCell
                cell.textLabel!.textColor = UIColor.white
                cell.textLabel!.text = "No outstanding tasks :)"
                return cell
                
            }else if authenticationStr == "YES" && self.tasks != nil && !self.tasks!.isEmpty {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: STExtTodayViewCellId) as! STExtTaskCell
                let task = self.tasks![indexPath.row]
                cell.dueDate.text = task.object(forKey: "ActivityDate") as? String
                cell.type.text = task.object(forKey: "Type") as? String
                cell.subject.text = task.object(forKey: "Subject") as? String
                return cell
            }else {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: STExtMessageCellId) as! UITableViewCell
                cell.textLabel!.textColor = UIColor.white
                cell.textLabel!.text = "Tap to login to Salesforce."
                cell.backgroundColor = UIColor.clear
                return cell
            }
            
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: STExtMessageCellId) as! UITableViewCell
            cell.textLabel!.textColor = UIColor.white
            cell.textLabel!.text = "Tap to login to Salesforce."
            cell.backgroundColor = UIColor.clear
            return cell
            
        }
    }
    
    /*!
     This is called when table view is about to draw a cell for a particular row.
     This is overriden to set background color.
     @param tableView -> the table view
     @param cell -> the cell
     @param indexPath the index path
     */
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    /*!
     This is called when the specified row is now selected.
     This is overriden to launch the main app
     @param tableView -> the tableView
     @param indexPath -> the index path
     */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Launch the main app.
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
        let url = NSURL(string:"sftasks://SalesforceToday")
        extensionContext!.open(url! as URL, completionHandler: nil)
    }
}
