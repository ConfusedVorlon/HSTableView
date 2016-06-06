//
//  HSTableView.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import UIKit

class HSTableView: UITableView, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    private var sections:[HSTVSection]=[HSTVSection]()
    private var pendingSections:[HSTVSection]?
    
    enum HSTableViewError: ErrorType {
        case RowDoesNotExist(indexPath:NSIndexPath)
        case SectionDoesNotExist(indexPath:NSIndexPath)
    }
    
    var tableInfo:HSTVTableInfo! {
        willSet (newTableInfo){
            newTableInfo.table=self
        }
    }
    
    func doInitialSetup()
    {
        self.delegate=self
        self.dataSource=self
        self.rowHeight=UITableViewAutomaticDimension
        self.tableInfo=HSTVTableInfo(table: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        doInitialSetup()
    }
    
    /** 
     Call this before using add row and add section. 
     Rows and sections can then be added without worrying about table inconsistency
     call applyDataUpdate() to apply changes
 */
    func startDataUpdate() -> Void {
        self.pendingSections=[HSTVSection]()
    }
    
    /**
     Updates the internal data model with the pending information
     Calls Reload data
 */
    func applyDataUpdate() -> Void {
        precondition(pendingSections != nil, "You can't apply an update withough starting one!")
        
        if NSThread.isMainThread()
        {
            self.sections=self.pendingSections!
            self.reloadData()
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), { 
                self.sections=self.pendingSections!
                self.reloadData()
            })
        }
        
        
    }
    
    /**
    Adds a row to the most recently added section in the pending data update.
     Call startDataUpdate before using, and applyDataUpdate to apply it.

     The convenience function += can also be used e.g. ```table+=row```
 */
    func addRow(row: HSTVRowInfo) -> HSTVRowInfo {
        precondition(pendingSections != nil, "Call startDataUpdate before using add row.")
        
        precondition(pendingSections!.last != nil, "Add a section before adding a row")
        
        pendingSections!.last!.addRow(row)
        return row
     }
    
    /**
     Adds a section to the pending data update
     Call startDataUpdate before using, and applyDataUpdate to apply it.
 */
    func addSection(section: HSTVSection) -> HSTVSection{
        precondition(pendingSections != nil, "Call startDataUpdate before using add section.")
        
        pendingSections!.append(section)
         
        return section;
    }
    
    func addSection(title: String?) -> HSTVSection{
        let newSection=HSTVSection(table: self);
        newSection.sectionInfo.title = title
        
        return addSection(newSection)
    }
    
    
    func rowInfoFor(indexPath:NSIndexPath) throws -> HSTVRowInfo {
        
        guard (indexPath.section<sections.count) else {
            throw HSTableViewError.SectionDoesNotExist(indexPath: indexPath)
        }
        
        let section = sections[indexPath.section]

        guard (indexPath.row<section.rows.count) else {
            throw HSTableViewError.RowDoesNotExist(indexPath: indexPath)
        }

        let rowInfo=section.rows[indexPath.row];
        rowInfo.lastIndexPath = indexPath
        
        return rowInfo
    }
    
    func sectionInfoFor(section: Int) throws -> HSTVSectionInfo {
        
        guard (section<sections.count) else {
            throw HSTableViewError.SectionDoesNotExist(indexPath: NSIndexPath.init(forRow: -1, inSection: section))
        }
        
        let section = sections[section]
 
        return section.sectionInfo
    }
    
    func delete(row: HSTVRowInfo)
    {
        row.section?.removeRow(row)
        let deleteArray=[row.lastIndexPath!]
        self.deleteRowsAtIndexPaths(deleteArray,withRowAnimation:UITableViewRowAnimation.Automatic)
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return sections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let ri = try! self.rowInfoFor(indexPath)
        return ri.cell()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    
    // MARK UITableViewDelegate
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        let ri = try! self.rowInfoFor(indexPath)
        ri.tableView(willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let ri = try! self.rowInfoFor(indexPath)
        ri.tableViewDidSelectRow()
    }
    
    func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath)
    {
        let ri = try! self.rowInfoFor(indexPath)
        ri.tableViewAccessoryButtonTapped()
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let ri = try! self.rowInfoFor(indexPath)
        return ri.tableViewEstimatedHeightForRow();
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let ri = try! self.rowInfoFor(indexPath)
        return ri.tableViewHeightForRow();
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        let si = try! self.sectionInfoFor(section)
        return si.tableViewHeightForHeaderInSection()
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let si = try! self.sectionInfoFor(section)
        return si.viewForHeaderInSection()
    }
    
    //MARK UITableViewDelegate Editing
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {

        let ri = try! self.rowInfoFor(indexPath)
        return (ri.inheritedEditingStyle == .Delete)
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let ri = try! self.rowInfoFor(indexPath)
        return ri.inheritedEditingStyle
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle==UITableViewCellEditingStyle.Delete)
        {
            let ri = try! self.rowInfoFor(indexPath)
            ri.tableViewDidDeleteRow()
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return nil
    }
}

func +=(left: HSTableView, right: HSTVRowInfo) -> HSTableView {
    left.addRow(right)
    return left
}
