//
//  HSTVSectionInfo.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import UIKit

open class HSTVSectionInfo: HSTVRowInfo {
    public static let defaultHeaderHeight:CGFloat = 40
    
    open var headerHeight:CGFloat? // Defaults to 40 if title or header is set, or 0 otherwise
    open var footerHeight:CGFloat? // Defaults to 0
    open var header:UIView?
    var index=0
    
    public init(table: HSTableView, section: HSTVSection?) {
        super.init()
        self.table=table
        self.section=section
    }
    
    override func nextResponder() -> HSTVRowInfo? {
        return table.info
    }
    
    func viewForHeaderInSection() -> UIView?
    {
        if let header = header {
            return header
        }
        
        if let title = self.inheritedTitle
        {
            let label=UILabel.init()
            label.text=title
            label.textAlignment=NSTextAlignment.center
            label.backgroundColor=UIColor.lightGray
            
            if #available(iOS 13.0, *) {
                label.backgroundColor = UIColor.secondarySystemBackground
                label.textColor = UIColor.label
            }
            

            return label
        }
        
        return nil
    }
    
    internal lazy var inheritedHeaderHeight : CGFloat? = {
        return self.inherited({ row -> CGFloat? in
            let section = row as! HSTVSectionInfo?
            return section?.headerHeight
        })
        
    }()
    
    internal lazy var inheritedFooterHeight : CGFloat? = {
        return self.inherited({ row -> CGFloat? in
            let section = row as! HSTVSectionInfo?
            return section?.footerHeight
        })
        
    }()
    
    func tableViewHeightForHeaderInSection() -> CGFloat
    {
        //If we don't have a header, and we don't have a title to auto-generate one, then zero height
        if header == nil && self.inheritedTitle == nil {
            return 0
        }
        
        return  inheritedHeaderHeight ?? HSTVSectionInfo.defaultHeaderHeight
    }
    
    func tableViewHeightForFooterInSection() -> CGFloat
    {
        if let height = inheritedFooterHeight
        {
            return height
        }
        else
        {
            return 0
        }
    }
}
