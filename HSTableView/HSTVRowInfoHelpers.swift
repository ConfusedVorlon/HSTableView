//
//  HSTVRowInfoPreference.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 04/06/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import UIKit

extension HSTVRowInfo {
    
    /**
     Convenience function that uses the click handler and styleBeforeDisplay handler to link a row to an NSUserDefault
     The checkmark shows the value of the default (or the opposite if checkmarkShowsForFalse is true)
     The true and false subtitles give the user more info. (Note - if you set one of these, you must set both)
 */
    func linkTo(defaultName: String, trueSubtitle: String?, falseSubtitle: String?, checkmarkShowsForFalse: Bool){
        
        assert( (trueSubtitle != nil && falseSubtitle != nil) || (trueSubtitle == nil && falseSubtitle == nil),"If you provide a trueSubtitle, or falseSubtitle, you must provide both")
        
        self.clickHandler = {
            (row) in
            let currentValue=NSUserDefaults.standardUserDefaults().boolForKey(defaultName)
            NSUserDefaults.standardUserDefaults().setBool(!currentValue, forKey: defaultName)
            row.redrawCell(UITableViewRowAnimation.Fade)
        };
        
        self.styleBeforeDisplayHandler = {
            (row,cell) in
            let value=NSUserDefaults.standardUserDefaults().boolForKey(defaultName)
            var checkmarkValue = value
            if checkmarkShowsForFalse {
                checkmarkValue = !value
            }
            if (value)
            {
                if (trueSubtitle != nil)
                {
                    cell.detailTextLabel?.text=trueSubtitle
                }
            }
            else
            {
                if (falseSubtitle != nil)
                {
                    cell.detailTextLabel?.text=falseSubtitle
                }
            }
            
            cell.accessoryType = checkmarkValue ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
        }
    }
    
    /**
     Convenience function that uses the click handler and styleBeforeDisplay handler to link a row to an NSUserDefault
     The checkmark shows the value of the default
     The true and false subtitles give the user more info. (Note - if you set one of these, you must set both)
     */
    func linkTo(defaultName: String, trueSubtitle: String?, falseSubtitle: String?){
        linkTo(defaultName, trueSubtitle: trueSubtitle, falseSubtitle: falseSubtitle, checkmarkShowsForFalse: false);
    }
    
    /**
    
 */
    func simpleDeleteHandler(row: HSTVRowInfo) {
        row.table!.delete(row)
    }
}