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
     Convenience function that uses the click handler and styleBeforeDisplay handler to update a checkmark
     The get and set functions let you deal with the result
     The true and false subtitles give the user more info. (Note - if you set one of these, you must set both)
     */
    public func handleCheckmark(checkedSubtitle: String? = nil, uncheckedSubtitle: String? = nil, get:@escaping () -> Bool, set:@escaping (Bool) -> Void){
        
        assert( (checkedSubtitle == nil) == (uncheckedSubtitle == nil),"If you provide a trueSubtitle, or falseSubtitle, you must provide both")
        
        self.clickHandler = {
            (row) in
            let currentValue=get()
            set(!currentValue)
            row.redrawCell(UITableView.RowAnimation.fade)
        };
        
        self.styleBeforeDisplayHandler = {
            (row,cell) in
            let value=get()
            let checkmarkValue = value
            
            if (value)
            {
                if (checkedSubtitle != nil)
                {
                    cell.detailTextLabel?.text=checkedSubtitle
                }
            }
            else
            {
                if (uncheckedSubtitle != nil)
                {
                    cell.detailTextLabel?.text=uncheckedSubtitle
                }
            }
            
            cell.accessoryType = checkmarkValue ? UITableViewCell.AccessoryType.checkmark : UITableViewCell.AccessoryType.none
            
        }
    }
    
    
    /**
     Convenience function that uses the click handler and styleBeforeDisplay handler to link a row to an NSUserDefault
     The checkmark shows the value of the default (or the opposite if checkmarkShowsForFalse is true)
     The true and false subtitles give the user more info. (Note - if you set one of these, you must set both)
     */
    public func handleCheckmark(userDefault:String, checkedSubtitle: String?, uncheckedSubtitle: String?, checkmarkShowsForFalse: Bool = false){
        
        
        handleCheckmark(checkedSubtitle: checkedSubtitle,
                        uncheckedSubtitle: uncheckedSubtitle,
                        get: { () -> Bool in
                            let value=UserDefaults.standard.bool(forKey: userDefault)
                            return checkmarkShowsForFalse ? !value : value
        }) { (newValue) in
            let value = checkmarkShowsForFalse ? !newValue : newValue
            UserDefaults.standard.set(value, forKey: userDefault)
        }
        
    }
    
    
    
    
    /// Simple delete handler that just gets rid of the row
    /// You can use this as 'row.deleteHandler=row.simpleDeleteHandler'
    ///
    /// - Parameter row: the row
    public func simpleDeleteHandler(_ row: HSTVRowInfo) {
        row.table!.delete(row)
    }
}
