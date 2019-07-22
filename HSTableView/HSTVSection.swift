//
//  HSTVSection.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import Foundation

/// HSTVSection holds an array of HSTVRows
public class HSTVSection {
    var rows:[HSTVRowInfo]=[HSTVRowInfo]()
    
    weak var table: HSTableView!
    
    public var info:HSTVSectionInfo! {
        willSet (newSectionInfo){
            newSectionInfo.section=self
            newSectionInfo.table=table;
        }
    }
    
    init (table: HSTableView) {
        self.table=table
        self.info=HSTVSectionInfo(table:table, section: self)
    }
    
    /**
     Adds a row to this section
     
     The convenience function += can also be used e.g. ```section+=row```
     */
    public func addRow(_ row: HSTVRowInfo) {
        row.section=self;
        row.table=table;
        rows.append(row)
    }
    
    func removeRow(_ row: HSTVRowInfo)
    {
        if let index = rows.firstIndex(of: row) {
            rows.remove(at: index)
        }
    }
    
}
