//
//  HSTVTableInfo.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import Foundation


/// This is the top responder in the chain:
/// HSTVRowInfo > HSTVSectionInfo > HSTVTableInfo
/// Any properties from lower sections can be set here to provide defaults
class HSTVTableInfo: HSTVSectionInfo {
    
    init(table: HSTableView) {
        super.init(table:table, section:nil)
    }
    
    override func nextResponder() -> HSTVRowInfo? {
        return nil;
    }

}
