//
//  HSTableViewRow.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import UIKit

typealias HSClickHandler = (HSTVRowInfo)->Void
typealias HSCellStyler = (HSTVRowInfo,UITableViewCell)->Void

func == (lhs: HSTVRowInfo, rhs: HSTVRowInfo) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

class HSTVRowInfo: Equatable {
    weak var section: HSTVSection?
    weak var table: HSTableView!
    var lastIndexPath: NSIndexPath!
    
    var style:UITableViewCellStyle? // Defaults to .Subtitle
    var nib:UINib?
    var reuseIdentifier:String?
    
/**
     The value of textLabel.text is always set to the value of title (even if it is nil)
     This means that if you have a custom cell with no textLabel, then the OS will create a textLabel.
     You'll want to make sure that is hidden either in your cell's initialisation, or in your styleAfterCreateHandler
     */
    var title:String?
    var titleColor:UIColor?
/**
     The value of detailTextLabel.text is always set to the value of subtitle (even if it is nil)
     */
    var subtitle:String?
    var subtitleColor:UIColor?
    
    var leftImageName:String?
    /**
     If set, then any image set through leftImageName will be rendered as a template with this colour
     */
    var leftImageColor:UIColor?
    /**
     If set, the chevron image is swapped for one rendered with the disclosure colour
     */
    var tintChevronDisclosures:Bool?
    var tintColor:UIColor?
    
    /**
     Note that only grey/default and none are honoured from iOS7
 */
    var selectionStyle:UITableViewCellSelectionStyle?
    var accessoryType:UITableViewCellAccessoryType?
    var editingStyle:UITableViewCellEditingStyle? //Defaults to .None
    
    var clickHandler:HSClickHandler?
    var deleteHandler:HSClickHandler?
    var accessoryClickHandler:HSClickHandler?
    var styleAfterCreateHandler:HSCellStyler?
    var styleBeforeDisplayHandler:HSCellStyler?

    
    var autoDeselect:Bool? // Defaults to true
    var rowHeight:CGFloat? // Defaults to UITableViewAutomaticDimension
    var estimatedRowHeight:CGFloat? // Defaults to UITableViewAutomaticDimension. Returns rowHeight if that is set.
    
    convenience init (title: String?)
    {
        self.init()
        self.title=title
    }
    
    convenience init (title: String?, subtitle: String?)
    {
        self.init()
        self.title=title
        self.subtitle=subtitle
    }
    
    func nextResponder() -> HSTVRowInfo? {
        let next=section?.sectionInfo
        
        return next
    }
    
    func makeNewCell(identifier: String, inheritedStyle: UITableViewCellStyle) -> UITableViewCell
    {
        return UITableViewCell(style: inheritedStyle , reuseIdentifier: identifier)
    }
    
    private lazy var cellIdentifier : String = {
        let theStyle = self.inheritedStyle ?? .Subtitle
        
        let identifier:String="\(theStyle)_\(self)_\(self.inheritedNib ?? "")_\(self.inheritedReuseIdentifier ?? "")_\(self.inheritedTintChevronDisclosures ?? false)"

        
        return identifier
    }()
    
    private var nibRegistrationTried : Bool = false
    
    func cell() -> UITableViewCell
    {
        if (!nibRegistrationTried)
        {
            nibRegistrationTried=true;
            
            if let nib = self.inheritedNib {
                //This will register once per row, rather than once per nib-type
                //Slightly inefficient, but probably not problematic
                self.table.registerNib(nib,forCellReuseIdentifier:self.cellIdentifier)
            }
        }
        
        let oldCell: UITableViewCell? = table.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        let cell = oldCell ?? makeNewCell(cellIdentifier, inheritedStyle: self.inheritedStyle)
        
        self.doInitialConfigurationFor(cell)
        
        return cell
    }
    
    func doInitialConfigurationFor(cell: UITableViewCell)
    {
        cell.textLabel?.text = inheritedTitle()
        cell.textLabel?.textColor = inheritedTitleColor()

        cell.detailTextLabel?.text = inheritedSubtitle()
        cell.detailTextLabel?.textColor = inheritedSubtitleColor()
        
        if let imageName=inheritedLeftImageName() {
            var image = UIImage.init(named: imageName)
            if let imageColour = inheritedLeftImageColor
            {
                image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                cell.imageView?.tintColor=imageColour
            }
            cell.imageView?.image=image
            
        }
        else
        {
            cell.imageView?.image=nil
        }
        
        cell.selectionStyle = inheritedSelectionStyle
        cell.accessoryType = inheritedAccessoryType()
        
        cell.tintColor = inheritedTintColor
        
        
        if let afterCreate = self.inheritedStyleAfterCreateHandler
        {
            if (inheritedReuseIdentifier==nil)
            {
                print("Warning: When using an afterCreate handler, you should set a reuse identifier. Otherwise, your cell can be re-used by a different row with a different (or no) afterCreate handler. IndexPath:\(self.lastIndexPath)")
            }
            afterCreate(self,cell)
        }
        
    }
    
    func redrawCell(withRowAnimation: UITableViewRowAnimation) -> Void {
        table.reloadRowsAtIndexPaths([self.lastIndexPath], withRowAnimation: withRowAnimation)
    }
    
    //MARK: inheritors
    
    internal func inherited<T>(getResult: (HSTVRowInfo?) -> T? ) -> T? {
        var responder : HSTVRowInfo? = self
        var theResult : T? = nil
        
        repeat {
            theResult=getResult(responder)
            responder=responder?.nextResponder()
        } while (theResult == nil && responder != nil)
        
        return theResult
    }
    
//    internal func inherited2<T>(getResult: (HSTVRowInfo?) -> T? ) -> T? {
  //      return inherited({ )

    //}
 
    
 
//    private func inherited2<T>(getResult: (HSTVRowInfo?) -> T? ) -> T? {
//        var responder : HSTVRowInfo? = self
//        var theSubtitle : T? = nil
//        
//        repeat {
//            theSubtitle=getResult(responder)
//            print("check: \(responder) get \(theSubtitle)")
//            
//            responder=responder?.nextResponder()
//            
//        } while (theSubtitle == nil && responder != nil)
//        
//        print ("return \(theSubtitle)")
//        
//        return theSubtitle
//    }
    
    
    //two things here;
    //1) trailing closure param doesn't need ()
    //2) for sinvle argument closure, you don't need to give the boilerplate, and can refer to first input argument with $0
    internal func inheritedTitle() -> String? { return inherited { $0?.title } }

//    internal func inheritedTitle() -> String? {
//        return inherited({ row -> String? in
//            return row?.title
//        })
//    }
    
    internal func inheritedSubtitle() -> String? { return inherited { $0?.subtitle } }

    
    internal func inheritedTitleColor() -> UIColor? { return inherited{ $0?.titleColor } }
    
    internal func inheritedSubtitleColor() -> UIColor? { return inherited{ $0?.subtitleColor }}
    
    internal func inheritedLeftImageName() -> String? { return inherited{ $0?.leftImageName }}
    
    internal lazy var inheritedLeftImageColor : UIColor? = { self.inherited { $0?.leftImageColor } }()
    
    internal lazy var inheritedTintChevronDisclosures : Bool? = { self.inherited { $0?.tintChevronDisclosures  } }()
    
    internal lazy var inheritedTintColor : UIColor? = { self.inherited{ $0?.tintColor } }()
    
    internal lazy var inheritedSelectionStyle : UITableViewCellSelectionStyle = {
        let style = self.inherited { $0?.selectionStyle }
        return style ?? .Default
    }()
    
    internal lazy var inheritedEditingStyle : UITableViewCellEditingStyle = {
        let style = self.inherited { $0?.editingStyle }
        return style ?? .None
    }()
    
    
    internal func inheritedAccessoryType() -> UITableViewCellAccessoryType {
        let style = inherited{ $0?.accessoryType }
        return style ?? .None
    }
    
    internal lazy var inheritedStyle: UITableViewCellStyle = {
        let style = self.inherited { $0?.style }
        return style ?? .Subtitle
    }()
    
    internal lazy var inheritedReuseIdentifier : String? = {
        return self.inherited({ row -> String? in
            return row?.reuseIdentifier
        })
    }()
    
    internal func inheritedClickHandler() -> HSClickHandler? {
        return inherited({ row -> HSClickHandler? in
            return row?.clickHandler
        })
    }
    
    internal func inheritedDeleteHandler() -> HSClickHandler? {
        return inherited({ row -> HSClickHandler? in
            return row?.deleteHandler
        })
    }
    
    internal func inheritedAccessoryClickHandler() -> HSClickHandler? {
        return inherited({ row -> HSClickHandler? in
            return row?.accessoryClickHandler
        })
    }
    
    internal lazy var inheritedStyleAfterCreateHandler : HSCellStyler? = {
        return self.inherited({ row -> HSCellStyler? in
            return row?.styleAfterCreateHandler
        })
    }()
    
    internal lazy var inheritedStyleBeforeDisplayHandler : HSCellStyler? = {
        return self.inherited({ row -> HSCellStyler? in
            return row?.styleBeforeDisplayHandler
        })
    }()
    
    internal func inheritedAutoDeselect() -> Bool {
        let autoDeselect = inherited({ row -> Bool? in
            return row?.autoDeselect
        })
        
        return autoDeselect ?? true
    }

    internal lazy var inheritedRowHeight : CGFloat = {
        let height = self.inherited({ row -> CGFloat? in
            return row?.rowHeight
        })
        
        return height ?? UITableViewAutomaticDimension
    }()
    
    internal lazy var inheritedEstimatedRowHeight : CGFloat = {
        if (self.inheritedRowHeight != UITableViewAutomaticDimension)
        {
            return self.inheritedRowHeight
        }
    
        let height = self.inherited({ row -> CGFloat? in
            return row?.estimatedRowHeight
        })
        
        return height ?? UITableViewAutomaticDimension
    }()
    
    internal lazy var inheritedNib : UINib? = {
        let nib = self.inherited({ row -> UINib? in
            return row?.nib
        })
        
        return nib
    }()
    
    
    //MARK: UITableView related delegate methods
    
    func tableView(willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        if inheritedTintChevronDisclosures == true {
            for case let button as UIButton in cell.subviews {
                let image = button.backgroundImageForState(.Normal)?.imageWithRenderingMode(.AlwaysTemplate)
                button.setBackgroundImage(image, forState: .Normal)
            }
            
            for disclosure in cell.subviews {
                if (NSStringFromClass(disclosure.dynamicType) == "UITableViewCellDetailDisclosureView") {
                    for case let imageView as UIImageView in disclosure.subviews {
                        let image = imageView.image?.imageWithRenderingMode(.AlwaysTemplate)
                        imageView.image = image
                    }
                }
            }
        }
        
        self.inheritedStyleBeforeDisplayHandler?(self,cell)
    }
    
    func tableViewHeightForRow() -> CGFloat
    {
        return self.inheritedRowHeight
    }
    
    func tableViewEstimatedHeightForRow() -> CGFloat {
        let estimatedHeight = self.inheritedEstimatedRowHeight
        
        if (estimatedHeight == UITableViewAutomaticDimension && self.inheritedNib != nil)
        {
            print("Warning: when using a nib, you should set estimatedRowHeight or rowHeight.\nCurrently using UITableViewAutomaticDimension for indexPath:\(self.lastIndexPath)")
        }
        
        return estimatedHeight
    }
    
    func tableViewDidSelectRow()
    {
        self.inheritedClickHandler()?(self)
        
        if (self.inheritedAutoDeselect())
        {
            self.table.deselectRowAtIndexPath(self.lastIndexPath, animated: true)
        }
    }
    
    func tableViewDidDeleteRow()
    {
        self.inheritedDeleteHandler()?(self)
    }
    
    func tableViewAccessoryButtonTapped()
    {
        self.inheritedAccessoryClickHandler()?(self)
    }
    
}