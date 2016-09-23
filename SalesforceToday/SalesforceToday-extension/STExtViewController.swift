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


@available(iOS 10.0, *)
@available(iOSApplicationExtension 10.0, *)
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
            
            return CGFloat(STExtTaskCellHeight * tasks!.count) + 50
            
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
        
        if #available(iOSApplicationExtension 10.0, *) {
            if #available(iOS 10.0, *) {
                self.extensionContext?.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
            } else {
                // Fallback on earlier versions
            }
        } else {
            var preferredSize = preferredContentSize
            preferredSize.height = self.preferredViewHeight
            preferredContentSize = preferredSize
            self.tableView.contentInset = UIEdgeInsetsMake(0, 15, 0, 0);
        };

        // Reload data
        self.tableView.reloadData()
        
    }
    
    @available(iOS 10.0, *)
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if #available(iOSApplicationExtension 10.0, *) {
            if #available(iOS 10.0, *) {
                if (activeDisplayMode == NCWidgetDisplayMode.expanded) {
                    self.preferredContentSize = CGSize(width: 0, height: 200)
                } else if (activeDisplayMode == NCWidgetDisplayMode.compact) {
                    self.preferredContentSize = maxSize;
                }
            } else {
                // Fallback on earlier versions
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    /*!
    This is called to give a widget an opportunity to update its contents.
    @param completionHandler -> the completion handler
    */
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
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
                let cell = tableView.dequeueReusableCell(withIdentifier: STExtMessageCellId, for: indexPath)
                cell.textLabel!.textColor = UIColor.black
                cell.textLabel!.text = "No outstanding tasks :)"
                return cell
                
            }else if authenticationStr == "YES" && self.tasks != nil && !self.tasks!.isEmpty {
                
                let cell = tableView.dequeueReusableCell(withIdentifier: STExtTodayViewCellId) as! STExtTaskCell
                
                let task = self.tasks![(indexPath as NSIndexPath).row]
                
                cell.dueDate.textColor = UIColor.black
                cell.dueDate.text = task.object(forKey: "ActivityDate") as? String
                cell.type.textColor = UIColor.black
                cell.type.text = task.object(forKey: "Type") as? String
                cell.subject.textColor = UIColor.black
                cell.subject.text = task.object(forKey: "Subject") as? String
                return cell
            }else {
                let cell = tableView.dequeueReusableCell(withIdentifier: STExtMessageCellId, for: indexPath)
                cell.textLabel!.textColor = UIColor.black
                cell.textLabel!.text = "Tap to login to Salesforce."
                cell.backgroundColor = UIColor.clear
                return cell
            }
            
        }else {
            let cell = tableView.dequeueReusableCell(withIdentifier: STExtMessageCellId, for: indexPath)
            cell.textLabel!.textColor = UIColor.black
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
        tableView.deselectRow(at: indexPath, animated: false)
        let url = URL(string:"sftasks://SalesforceToday")
        extensionContext!.open(url!, completionHandler: nil)
    }
}
