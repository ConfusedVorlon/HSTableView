//
//  HSTableView.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import UIKit

/// Table view holds an array of sections. 
/// Changes are made to pending sections, then swapped in on the main thread (with startDataUpdate / ApplyDataUpdate)
class HSTableView: UITableView, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    fileprivate var sections:[HSTVSection]=[HSTVSection]()
    fileprivate var pendingSections:[HSTVSection]?
    
    enum HSTableViewError: Error {
        case rowDoesNotExist(indexPath:IndexPath)
        case sectionDoesNotExist(indexPath:IndexPath)
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
     TODO - At the moment, this just calls reload data
     In future ths will sensibly add/remove rows based on changes relative to the existing data
     Calls Reload data
 */
    func applyDataUpdate() -> Void {
        precondition(pendingSections != nil, "You can't apply an update withough starting one!")
        
        if Thread.isMainThread
        {
            self.sections=self.pendingSections!
            self.reloadData()
        }
        else
        {
            DispatchQueue.main.async(execute: { 
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
    @discardableResult func addRow(_ row: HSTVRowInfo) -> HSTVRowInfo {
        precondition(pendingSections != nil, "Call startDataUpdate before using add row.")
        
        precondition(pendingSections!.last != nil, "Add a section before adding a row")
        
        pendingSections!.last!.addRow(row)
        return row
     }
    
    /**
     Adds a section to the pending data update
     Call startDataUpdate before using, and applyDataUpdate to apply it.
 */
    @discardableResult func addSection(_ section: HSTVSection) -> HSTVSection{
        precondition(pendingSections != nil, "Call startDataUpdate before using add section.")
        
        pendingSections!.append(section)
         
        return section;
    }
    
    /// Add a simple section with just a title
    ///
    /// - Parameter title: the title
    /// - Returns: the section
    @discardableResult func addSection(_ title: String?) -> HSTVSection{
        let newSection=HSTVSection(table: self);
        newSection.sectionInfo.title = title
        
        return addSection(newSection)
    }
    
    
    func rowInfoFor(_ indexPath:IndexPath) throws -> HSTVRowInfo {
        
        guard (indexPath.section<sections.count) else {
            throw HSTableViewError.sectionDoesNotExist(indexPath: indexPath)
        }
        
        let section = sections[indexPath.section]

        guard (indexPath.row<section.rows.count) else {
            throw HSTableViewError.rowDoesNotExist(indexPath: indexPath)
        }

        let rowInfo=section.rows[indexPath.row];
        rowInfo.lastIndexPath = indexPath
        
        return rowInfo
    }
    
    func sectionInfoFor(_ section: Int) throws -> HSTVSectionInfo {
        
        guard (section<sections.count) else {
            throw HSTableViewError.sectionDoesNotExist(indexPath: IndexPath.init(row: -1, section: section))
        }
        
        let section = sections[section]
 
        return section.sectionInfo
    }
    
    func delete(_ row: HSTVRowInfo)
    {
        row.section?.removeRow(row)
        let deleteArray=[row.lastIndexPath!]
        self.deleteRows(at: deleteArray as [IndexPath],with:UITableViewRowAnimation.automatic)
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let ri = try! self.rowInfoFor(indexPath)
        return ri.cell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    
    // MARK UITableViewDelegate
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let ri = try! self.rowInfoFor(indexPath)
        ri.tableView(willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let ri = try! self.rowInfoFor(indexPath)
        ri.tableViewDidSelectRow()
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        let ri = try! self.rowInfoFor(indexPath)
        ri.tableViewAccessoryButtonTapped()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let ri = try! self.rowInfoFor(indexPath)
        return ri.tableViewEstimatedHeightForRow();
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let ri = try! self.rowInfoFor(indexPath)
        return ri.tableViewHeightForRow();
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        let si = try! self.sectionInfoFor(section)
        return si.tableViewHeightForHeaderInSection()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let si = try! self.sectionInfoFor(section)
        return si.viewForHeaderInSection()
    }
    
    //MARK UITableViewDelegate Editing
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        let ri = try! self.rowInfoFor(indexPath)
        return (ri.inheritedEditingStyle == .delete)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let ri = try! self.rowInfoFor(indexPath)
        return ri.inheritedEditingStyle
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle==UITableViewCellEditingStyle.delete)
        {
            let ri = try! self.rowInfoFor(indexPath)
            ri.tableViewDidDeleteRow()
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
}

@discardableResult func +=(left: HSTableView, right: HSTVRowInfo) -> HSTableView {
    left.addRow(right)
    return left
}
