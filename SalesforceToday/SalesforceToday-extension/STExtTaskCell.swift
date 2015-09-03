//
//  STExtTaskCell.swift
//  SalesforceToday
//
//  Created by Bhavna Gupta on 27/07/15.
//  Copyright (c) 2015 Metacube. All rights reserved.
//

import Foundation
import UIKit

class STExtTaskCell : UITableViewCell {
    
    @IBOutlet var dueDate : UILabel!
    
    @IBOutlet var subject : UILabel!
    
    @IBOutlet var type : UILabel!

    
    // This function is called to prepare the cell.

    override func prepareForReuse() {
        dueDate.text = ""
        dueDate.textColor = UIColor.whiteColor()
        subject.text = ""
        subject.textColor = UIColor.whiteColor()
        type.text = ""
        type.textColor = UIColor.whiteColor()
    }
}