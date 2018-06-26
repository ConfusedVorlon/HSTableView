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
open class HSTableView: UITableView, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    public var sections:[HSTVSection]=[HSTVSection]()
    fileprivate var pendingSections:[HSTVSection]?

    enum HSTableViewError: Error {
        case rowDoesNotExist(indexPath:IndexPath)
        case sectionDoesNotExist(indexPath:IndexPath)
    }

    public var info:HSTVTableInfo! {
        willSet (newTableInfo){
            newTableInfo.table=self
        }
    }

    func doInitialSetup()
    {
        self.delegate=self
        self.dataSource=self
        self.rowHeight=UITableViewAutomaticDimension
        self.info=HSTVTableInfo(table: self)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
    }

    public override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        doInitialSetup()
    }

    /**
     Call this before using add row and add section.
     Rows and sections can then be added without worrying about table inconsistency
     call applyDataUpdate() to apply changes
 */
    public func startDataUpdate() -> Void {
        self.pendingSections=[HSTVSection]()
    }

    /**
     Updates the internal data model with the pending information
     TODO - At the moment, this just calls reload data
     In future ths will sensibly add/remove rows based on changes relative to the existing data
     Calls Reload data
 */
    public func applyDataUpdate(animated:Bool = false) -> Void {
        precondition(pendingSections != nil, "You can't apply an update withough starting one!")

        if Thread.isMainThread
        {
            self.sections=self.pendingSections!
            self.updateData(animated: animated)
        }
        else
        {
            DispatchQueue.main.async(execute: {
                self.sections=self.pendingSections!
                self.reloadData()
            })
        }
    }

    private func updateData(animated:Bool) {
        self.reloadData()
    }

    /**
    Adds a row to the most recently added section in the pending data update.
     Call startDataUpdate before using, and applyDataUpdate to apply it.

     The convenience function += can also be used e.g. ```table+=row```
 */
    @discardableResult public func addRow(_ row: HSTVRowInfo) -> HSTVRowInfo {
        precondition(pendingSections != nil, "Call startDataUpdate before using add row.")

        precondition(pendingSections!.last != nil, "Add a section before adding a row")

        pendingSections!.last!.addRow(row)
        return row
     }

    /**
     Adds a section to the pending data update
     Call startDataUpdate before using, and applyDataUpdate to apply it.
 */
    @discardableResult public func addSection(_ section: HSTVSection) -> HSTVSection{
        precondition(pendingSections != nil, "Call startDataUpdate before using add section.")

        pendingSections!.append(section)

        return section;
    }

    /// Add a simple section with just a title
    ///
    /// - Parameter title: the title
    /// - Returns: the section
    @discardableResult public func addSection(_ title: String? = nil) -> HSTVSection{
        let newSection=HSTVSection(table: self);
        newSection.info.title = title

        return addSection(newSection)
    }


    func infoFor(_ indexPath:IndexPath) throws -> HSTVRowInfo {

        guard (indexPath.section<sections.count) else {
            throw HSTableViewError.sectionDoesNotExist(indexPath: indexPath)
        }

        let section = sections[indexPath.section]

        guard (indexPath.row<section.rows.count) else {
            throw HSTableViewError.rowDoesNotExist(indexPath: indexPath)
        }

        let info=section.rows[indexPath.row];
        info.lastIndexPath = indexPath

        return info
    }

    func infoFor(_ section: Int) throws -> HSTVSectionInfo {

        guard (section<sections.count) else {
            throw HSTableViewError.sectionDoesNotExist(indexPath: IndexPath.init(row: -1, section: section))
        }

        let section = sections[section]

        return section.info
    }

    public func delete(_ row: HSTVRowInfo)
    {
        row.section?.removeRow(row)
        let deleteArray=[row.lastIndexPath!]
        self.deleteRows(at: deleteArray as [IndexPath],with:UITableViewRowAnimation.automatic)
    }

    // filter function should return true to show row, false to hide it
    public func filter(showRowFunction : HSCellFilter)
    {
        for section in sections {
            for row in section.rows {
                row.hidden = !showRowFunction(row)
            }
        }

        self.beginUpdates()
        self.endUpdates()
    }

    // MARK: UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int{
        return sections.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let ri = try! self.infoFor(indexPath)
        return ri.cell()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }


    // MARK UITableViewDelegate

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let ri = try! self.infoFor(indexPath)
        ri.tableView(willDisplayCell: cell, forRowAtIndexPath: indexPath)
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let ri = try! self.infoFor(indexPath)
        ri.tableViewDidSelectRow()
    }

    public func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        let ri = try! self.infoFor(indexPath)
        ri.tableViewAccessoryButtonTapped()
    }

    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let ri = try! self.infoFor(indexPath)
        if ri.inheritedHidden() == true {
            return 0
        }
        return ri.tableViewEstimatedHeightForRow();
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let ri = try! self.infoFor(indexPath)
        return ri.tableViewHeightForRow();
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        let si = try! self.infoFor(section)
        return si.tableViewHeightForHeaderInSection()
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let si = try! self.infoFor(section)
        return si.viewForHeaderInSection()
    }

    //MARK UITableViewDelegate Editing

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        let ri = try! self.infoFor(indexPath)
        return (ri.inheritedEditingStyle == .delete)
    }

    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let ri = try! self.infoFor(indexPath)
        return ri.inheritedEditingStyle
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle==UITableViewCellEditingStyle.delete)
        {
            let ri = try! self.infoFor(indexPath)
            ri.tableViewDidDeleteRow()
        }
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
}

@discardableResult public func +=(left: HSTableView, right: HSTVRowInfo) -> HSTableView {
    left.addRow(right)
    return left
}
