//
//  HSTVSection.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import Foundation

class HSTVSection {
    var rows:[HSTVRowInfo]=[HSTVRowInfo]()
    
    weak var table: HSTableView!
    
    var sectionInfo:HSTVSectionInfo! {
        willSet (newSectionInfo){
            newSectionInfo.section=self
            newSectionInfo.table=table;
        }
    }
    
    init (table: HSTableView) {
        self.table=table
        self.sectionInfo=HSTVSectionInfo(table:table, section: self)
    }
    
    func addRow(row: HSTVRowInfo) {
        row.section=self;
        row.table=table;
        rows.append(row)
        
        row.nextResponder()
    }
    
    func removeRow(row: HSTVRowInfo)
    {
        if let index = rows.indexOf(row) {
            rows.removeAtIndex(index)
        }
    }
    
}