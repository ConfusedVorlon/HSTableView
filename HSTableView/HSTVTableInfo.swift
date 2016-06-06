//
//  HSTVTableInfo.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import Foundation

class HSTVTableInfo: HSTVSectionInfo {
    
    init(table: HSTableView) {
        super.init(table:table, section:nil)
    }
    
    override func nextResponder() -> HSTVRowInfo? {
        return nil;
    }

}