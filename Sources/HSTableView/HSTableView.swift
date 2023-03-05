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
    open var sections:[HSTVSection]=[HSTVSection]()
    fileprivate var pendingSections:[HSTVSection]?

    enum HSTableViewError: Error {
        case rowDoesNotExist(indexPath:IndexPath)
        case sectionDoesNotExist(index:Int)
    }

    open var info:HSTVTableInfo! {
        willSet (newTableInfo){
            newTableInfo.table=self
        }
    }

    func doInitialSetup()
    {
        self.delegate=self
        self.dataSource=self
        self.rowHeight=UITableView.automaticDimension
        self.info=HSTVTableInfo(table: self)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        doInitialSetup()
    }

    public override init(frame: CGRect,
                         style: UITableView.Style) {
        super.init(frame: frame, style: style)
        doInitialSetup()
    }

    /**
     Call this before using add row and add section.
     Rows and sections can then be added without worrying about table inconsistency
     call applyDataUpdate() to apply changes
 */
    open func startDataUpdate() -> Void {
        self.pendingSections=[HSTVSection]()
    }

    /**
     Updates the internal data model with the pending information
     TODO - At the moment, this just calls reload data
     In future ths will sensibly add/remove rows based on changes relative to the existing data
     Calls Reload data
 */
    open func applyDataUpdate(animated:Bool = false) -> Void {
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
                self.updateData(animated: animated)
            })
        }
    }

    private func updateData(animated:Bool) {
        if self.window != nil {
            self.reloadData()
        }  
    }

    /**
    Adds a row to the most recently added section in the pending data update.
     Call startDataUpdate before using, and applyDataUpdate to apply it.

     The convenience function += can also be used e.g. ```table+=row```
 */
    @discardableResult open func addRow(_ row: HSTVRowInfo) -> HSTVRowInfo {
        precondition(pendingSections != nil, "Call startDataUpdate before using add row.")

        precondition(pendingSections!.last != nil, "Add a section before adding a row")

        pendingSections!.last!.addRow(row)
        return row
     }

    /**
     Adds a section to the pending data update
     Call startDataUpdate before using, and applyDataUpdate to apply it.
 */
    @discardableResult open func addSection(_ section: HSTVSection) -> HSTVSection{
        precondition(pendingSections != nil, "Call startDataUpdate before using add section.")

        pendingSections!.append(section)

        return section;
    }

    /// Add a simple section with just a title
    ///
    /// - Parameter title: the title
    /// - Returns: the section
    @discardableResult open func addSection(_ title: String? = nil) -> HSTVSection{
        let newSection=HSTVSection(table: self);
        newSection.info.title = title

        return addSection(newSection)
    }
    
    /// Add a simple section with a view
    ///
    /// - Parameter view: the header
    /// - Parameter height: the header height
    /// - Returns: the section
    @discardableResult open func addSection(_ view: UIView, height:CGFloat = HSTVSectionInfo.defaultHeaderHeight ) -> HSTVSection{
        let newSection=HSTVSection(table: self);
        newSection.info.header = view
        newSection.info.headerHeight = height

        return addSection(newSection)
    }


    //You shouldn't really need this except in obscure subclassing
    open func sectionFor(_ index:Int) throws -> HSTVSection {
        guard (index<sections.count) else {
            throw HSTableViewError.sectionDoesNotExist(index: index)
        }

        return sections[index]
    }
    
    //You shouldn't really need this except in obscure subclassing
    open func infoFor(_ indexPath:IndexPath) throws -> HSTVRowInfo {

        let section = try sectionFor(indexPath.section)

        guard (indexPath.row<section.rows.count) else {
            throw HSTableViewError.rowDoesNotExist(indexPath: indexPath)
        }

        let info=section.rows[indexPath.row];
        info.lastIndexPath = indexPath

        return info
    }

    //You shouldn't really need this except in obscure subclassing
    open func infoFor(_ section: Int) throws -> HSTVSectionInfo {

        let section = try sectionFor(section)

        return section.info
    }

    open func delete(_ row: HSTVRowInfo)
    {
        self.delete(rows:[row])
    }
    
    open func delete(rows: [HSTVRowInfo])
    {
        for row in rows {
            row.section?.removeRow(row)
        }
        let paths:[IndexPath] = rows.compactMap { $0.lastIndexPath }
        self.deleteRows(at: paths,with:UITableView.RowAnimation.automatic)
        
    }
    
    // MARK: Index
    private var sectionIndexTitles:[String]?
    open var sectionForIndex:Int? {
        didSet {
            prepareSectionIndex()
        }
    }
    
    func prepareSectionIndex() {
        defer {
            self.reloadSectionIndexTitles()
        }
        
        guard let sectionForIndex = sectionForIndex else {
            self.sectionIndexTitles = nil
            return
        }
        

        guard let section = try? sectionFor(sectionForIndex) else {
            print("Error: Trying to index on a section that doesn't exist: \(sectionForIndex)")
            self.sectionIndexTitles = nil
            return
        }
        
        
        let titles = section.rows.compactMap { (info) -> String? in
            if let substring = info.title?.prefix(1) {
                return String(substring).uppercased()
            }
            return nil
        }
        
        let uniqueTitles:[String] = Array(Set(titles))
        let sortedTitles = uniqueTitles.sorted(by:{ x,y in
            return x.localizedStandardCompare(y) == ComparisonResult.orderedAscending
        })
        
        sectionIndexTitles = sortedTitles
    
    }
    
    // MARK: Manage Visibility


    /// Filter visible rows
    /// - Parameter showRowFunction: return true to show row, false to hide it
    open func filter(showRowFunction : HSCellFilter)
    {
        for section in sections {
            for row in section.rows {
                row.hidden = !showRowFunction(row)
            }
        }

        self.beginUpdates()
        self.reloadData()
        self.endUpdates()
    }

    
    /// Show or hide a section
    ///
    /// - Parameters:
    ///   - section: section index
    ///   - visibility: true, false or toggle if nil
    ///   - apply: if true, apply the change
    open func show(section sectionIndex:Int,
                   visibility newVisiblity:Bool?,
                   apply:Bool = true) {
        guard let sectionInfo = try?  self.infoFor(sectionIndex) else {
            return
        }
        var visibile =  (sectionInfo.hidden == nil || sectionInfo.hidden == false)
        if let newVisiblity = newVisiblity {
            visibile = newVisiblity
        }
        else {
            visibile = !visibile
        }
        
        sectionInfo.hidden = !visibile
          
        if apply {
            self.beginUpdates()
            self.reloadData()
            self.endUpdates()
        }
    }
    
    // MARK: UITableViewDataSource

    open func numberOfSections(in tableView: UITableView) -> Int{
        return sections.count
    }

    open func tableView(_ tableView: UITableView,
                        cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let ri = try? self.infoFor(indexPath) else {
            return UITableViewCell(style: .default,
                                   reuseIdentifier: nil)
        }
        return ri.cell()
    }

    open func tableView(_ tableView: UITableView,
                        numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionIndexTitles
    }
    
    open func tableView(_ tableView: UITableView,
                        sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let sectionForIndex = sectionForIndex {
            var selectedIndexPath = IndexPath.init(row: 0, section: sectionForIndex)
            for rowIndex in 0..<numberOfRows(inSection: sectionForIndex) {
                let rowIndexPath = IndexPath.init(row: rowIndex, section: sectionForIndex)
                if let info = try? infoFor(rowIndexPath),
                    let rowTitle = info.title {
                    let comparison = rowTitle.localizedCaseInsensitiveCompare(title)
                    if comparison == .orderedAscending {
                        selectedIndexPath = rowIndexPath
                    }
                    else {
                        break
                    }
                }
            }
            
            self.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .top)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.deselectRow(at: selectedIndexPath, animated: true)
            }
            
        }
        
        return -1
    }

    // MARK: UITableViewDelegate

    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath)
    {
        guard let ri = try? self.infoFor(indexPath) else {
            return
        }
        ri.tableView(willDisplayCell: cell,
                     forRowAtIndexPath: indexPath)
    }

    open func tableView(_ tableView: UITableView,
                        didSelectRowAt indexPath: IndexPath)
    {
        guard let ri = try? self.infoFor(indexPath) else {
            return
        }
        ri.tableViewDidSelectRow()
    }

    open func tableView(_ tableView: UITableView,
                        accessoryButtonTappedForRowWith indexPath: IndexPath)
    {
        guard let ri = try? self.infoFor(indexPath) else {
            return
        }
        ri.tableViewAccessoryButtonTapped()
    }

    open func tableView(_ tableView: UITableView,
                        estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let ri = try? self.infoFor(indexPath) else {
            return 0
        }
        if ri.inheritedHidden == true {
            return 0
        }
        return ri.tableViewEstimatedHeightForRow();
    }

    open func tableView(_ tableView: UITableView,
                        heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        guard let ri = try? self.infoFor(indexPath) else {
            return 0
        }
        return ri.tableViewHeightForRow();
    }

    open func tableView(_ tableView: UITableView,
                        heightForHeaderInSection section: Int) -> CGFloat
    {
        guard let si = try? self.infoFor(section) else {
            return 0
        }
        return si.tableViewHeightForHeaderInSection()
    }

    open func tableView(_ tableView: UITableView,
                        viewForHeaderInSection section: Int) -> UIView?
    {
        guard let si = try? self.infoFor(section) else {
            return nil
        }
        return si.viewForHeaderInSection()
    }

    //MARK UITableViewDelegate Editing

    open func tableView(_ tableView: UITableView,
                        canEditRowAt indexPath: IndexPath) -> Bool {

        guard let ri = try? self.infoFor(indexPath) else {
            return false
        }
        return (ri.inheritedEditingStyle == .delete)
    }

    open func tableView(_ tableView: UITableView,
                        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        guard let ri = try? self.infoFor(indexPath) else {
            return .none
        }
        return ri.inheritedEditingStyle
    }

    open func tableView(_ tableView: UITableView,
                        commit editingStyle: UITableViewCell.EditingStyle,
                        forRowAt indexPath: IndexPath) {
 
        if (editingStyle==UITableViewCell.EditingStyle.delete)
        {
            guard let ri = try? self.infoFor(indexPath) else {
                return
            }
            ri.tableViewDidDeleteRow()
        }
    }

    open func tableView(_ tableView: UITableView,
                        editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
}

@discardableResult public func +=(left: HSTableView, right: HSTVRowInfo) -> HSTableView {
    left.addRow(right)
    return left
}
