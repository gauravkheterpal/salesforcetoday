//
//  STTaskListCell.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//


class STTaskListCell : UITableViewCell {
    
    @IBOutlet var dueDate : UILabel!
    

    @IBOutlet var subject : UILabel!
    
    
    @IBOutlet var priority : UILabel!
    
    
    @IBOutlet var status : UILabel!
    
    // This function is called to prepare the cell.

    override func prepareForReuse() {
        dueDate.text = ""
        dueDate.backgroundColor = UIColor.clearColor()
        subject.text = ""
        subject.backgroundColor = UIColor.clearColor()
        priority.text = ""
        priority.backgroundColor = UIColor.clearColor()
        status.text = ""
        status.backgroundColor = UIColor.clearColor()
    }
}