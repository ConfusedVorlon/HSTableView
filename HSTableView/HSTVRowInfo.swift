//
//  HSTableViewRow.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 30/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import UIKit

public typealias HSClickHandler = (HSTVRowInfo)->Void
public typealias HSCellStyler = (HSTVRowInfo,UITableViewCell)->Void
public typealias HSCellFilter = (HSTVRowInfo)->Bool

public func == (lhs: HSTVRowInfo, rhs: HSTVRowInfo) -> Bool {
    return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
}

open class HSTVRowInfo: Equatable {
    weak var section: HSTVSection?
    weak var table: HSTableView!
    public var lastIndexPath: IndexPath!
    
    public var style:UITableViewCellStyle? // Defaults to .Subtitle
    public var nib:UINib?
    public var reuseIdentifier:String? //If you have manually registered a class or prototype with an identifier - then specify it here
    public var reuseTag:String? // If you are just using a style, then a reuse identifier will be generated automatically based on any specified XIB, style or chevron. The reuseTag will be added to the identifier.
    
    
    public var customInfo:Any?
    
/**
     The value of textLabel.text is always set to the value of title (even if it is nil)
     This means that if you have a custom cell with no textLabel, then the OS will create a textLabel.
     You'll want to make sure that is hidden either in your cell's initialisation, or in your styleAfterCreateHandler
     */
    public var title:String?
    public var titleColor:UIColor?
/**
     The value of detailTextLabel.text is always set to the value of subtitle (even if it is nil)
     */
    public var subtitle:String?
    public var subtitleColor:UIColor?
    
    public var leftImageName:String?
    /**
     If set, then any image set through leftImageName will be rendered as a template with this colour
     */
    public var leftImageColor:UIColor?
    /**
     If set, the chevron image is swapped for one rendered with the disclosure colour
     */
    public var tintChevronDisclosures:Bool?
    public var tintColor:UIColor?
    
    /**
     Note that only grey/default and none are honoured from iOS7
 */
    public var selectionStyle:UITableViewCellSelectionStyle?
    public var accessoryType:UITableViewCellAccessoryType?
    public var editingStyle:UITableViewCellEditingStyle? //Defaults to .None
    
    public var clickHandler:HSClickHandler?
    public var deleteHandler:HSClickHandler?
    public var accessoryClickHandler:HSClickHandler?
    public var styleAfterCreateHandler:HSCellStyler?
    public var styleBeforeDisplayHandler:HSCellStyler?

    
    public var autoDeselect:Bool? // Defaults to true
    public var rowHeight:CGFloat? // Defaults to UITableViewAutomaticDimension
    public var estimatedRowHeight:CGFloat? // Defaults to UITableViewAutomaticDimension. Returns rowHeight if that is set.
    
    // Rows drawn at zero height if hidden. This allows animation in/out
    // Setting non-hidden sets this to nil so that it allows higher rows in the responder chain to override
    public var _hidden:Bool?
    public var hidden:Bool? {
        set {
            if newValue == false {
                _hidden = nil
            }
            else {
                _hidden = newValue
            }
        }
        get {
            return _hidden
        }

    }
    
    public init() {
        
    }
    
    public init (title: String?, subtitle: String? = nil, selectionStyle:UITableViewCellSelectionStyle? = nil, clickHandler:HSClickHandler? = nil)
    {
        self.title = title
        self.subtitle = subtitle
        self.selectionStyle = selectionStyle
        self.clickHandler = clickHandler
    }
    
    func nextResponder() -> HSTVRowInfo? {
        let next=section?.info
        
        return next
    }
    
    open func makeNewCell(_ identifier: String, inheritedStyle: UITableViewCellStyle) -> UITableViewCell
    {
        let cell = UITableViewCell(style: inheritedStyle , reuseIdentifier: identifier)
        cell.clipsToBounds = true //Otherwise standard cells won't clip to bounds, and subtitles display for 0-height cells.
        return cell
    }
    
    fileprivate lazy var cellIdentifier : String = {
        if self.inheritedReuseIdentifier != nil {
            return self.inheritedReuseIdentifier!
        }
        
        let theStyle = self.inheritedStyle
        let theReuseTag = self.inheritedReuseTag
        
        let identifier:String="\(theStyle)_\(self)_\(String(describing:self.inheritedNib))_\(String(describing:theReuseTag))_\(self.inheritedTintChevronDisclosures ?? false)"
    
        return identifier
    }()
    
    fileprivate var nibRegistrationTried : Bool = false
    
    func cell() -> UITableViewCell
    {
        if (!nibRegistrationTried)
        {
            nibRegistrationTried=true;
            
            if let nib = self.inheritedNib {
                //This will register once per row, rather than once per nib-type
                //Slightly inefficient, but probably not problematic
                self.table.register(nib,forCellReuseIdentifier:self.cellIdentifier)
            }
        }
        
        let oldCell: UITableViewCell? = table.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        let cell = oldCell ?? makeNewCell(cellIdentifier, inheritedStyle: self.inheritedStyle)
        
        self.doInitialConfigurationFor(cell)
        
        return cell
    }
    
    func doInitialConfigurationFor(_ cell: UITableViewCell)
    {
        cell.textLabel?.text = inheritedTitle()
        cell.textLabel?.textColor = inheritedTitleColor()

        cell.detailTextLabel?.text = inheritedSubtitle()
        cell.detailTextLabel?.textColor = inheritedSubtitleColor()
        
        if let imageName=inheritedLeftImageName() {
            var image = UIImage.init(named: imageName)
            if let imageColour = inheritedLeftImageColor
            {
                image = image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
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
            if (inheritedReuseIdentifier==nil && inheritedReuseTag==nil)
            {
                print("Warning: When using an afterCreate handler, you should set a reuse tag or reuseIdentifier. Otherwise, if you change your cell, then it can be re-used later by a row which doesn't make the same changes. IndexPath:\(String(describing: self.lastIndexPath))")
            }
            afterCreate(self,cell)
        }
        
    }
    
    public func redrawCell(_ withRowAnimation: UITableViewRowAnimation) -> Void {
        table.reloadRows(at: [self.lastIndexPath], with: withRowAnimation)
    }
    
    //MARK: inheritors
    
    internal func inherited<T>(_ getResult: (HSTVRowInfo?) -> T? ) -> T? {
        var responder : HSTVRowInfo? = self
        var theResult : T? = nil
        
        repeat {
            theResult=getResult(responder)
            responder=responder?.nextResponder()
        } while (theResult == nil && responder != nil)
        
        return theResult
    }


    
    //two things here;
    //1) trailing closure param doesn't need ()
    //2) for single argument closure, you don't need to give the boilerplate, and can refer to first input argument with $0
    internal func inheritedTitle() -> String? { return inherited { $0?.title } }

    internal func inheritedSubtitle() -> String? { return inherited { $0?.subtitle } }
    
    internal func inheritedTitleColor() -> UIColor? { return inherited{ $0?.titleColor } }
    
    internal func inheritedSubtitleColor() -> UIColor? { return inherited{ $0?.subtitleColor }}
    
    internal func inheritedLeftImageName() -> String? { return inherited{ $0?.leftImageName }}
    
    internal func inheritedHidden() -> Bool? { return inherited{ $0?.hidden }}
    
    internal lazy var inheritedLeftImageColor : UIColor? = { self.inherited { $0?.leftImageColor } }()
    
    internal lazy var inheritedTintChevronDisclosures : Bool? = { self.inherited { $0?.tintChevronDisclosures  } }()
    
    internal lazy var inheritedTintColor : UIColor? = { self.inherited{ $0?.tintColor } }()
    
    internal lazy var inheritedSelectionStyle : UITableViewCellSelectionStyle = {
        let style = self.inherited { $0?.selectionStyle }
        return style ?? .default
    }()
    
    internal lazy var inheritedEditingStyle : UITableViewCellEditingStyle = {
        let style = self.inherited { $0?.editingStyle }
        return style ?? .none
    }()
    
    
    internal func inheritedAccessoryType() -> UITableViewCellAccessoryType {
        let style = inherited{ $0?.accessoryType }
        return style ?? .none
    }
    
    internal lazy var inheritedStyle: UITableViewCellStyle = {
        let style = self.inherited { $0?.style }
        return style ?? .subtitle
    }()
    
    internal lazy var inheritedReuseIdentifier : String? = {
        return self.inherited({ $0?.reuseIdentifier })
    }()

    internal lazy var inheritedReuseTag : String? = {
        return self.inherited({ $0?.reuseTag })
    }()
    
    internal func inheritedClickHandler() -> HSClickHandler? {
        return inherited({ $0?.clickHandler  })
    }
    
    internal func inheritedDeleteHandler() -> HSClickHandler? {
        return inherited({ $0?.deleteHandler  })
    }
    
    internal func inheritedAccessoryClickHandler() -> HSClickHandler? {
        return inherited({ $0?.accessoryClickHandler })
    }
    
    internal lazy var inheritedStyleAfterCreateHandler : HSCellStyler? = {
        return self.inherited({ $0?.styleAfterCreateHandler })
    }()
    
    internal lazy var inheritedStyleBeforeDisplayHandler : HSCellStyler? = {
        return self.inherited({ $0?.styleBeforeDisplayHandler
        })
    }()
    
    internal func inheritedAutoDeselect() -> Bool {
        let autoDeselect = inherited({ $0?.autoDeselect
        })
        
        return autoDeselect ?? true
    }

    internal lazy var inheritedRowHeight : CGFloat = {
        let height = self.inherited { $0?.rowHeight }
        return height ?? UITableViewAutomaticDimension
    }()
    
    
    internal lazy var inheritedEstimatedRowHeight : CGFloat = {
        if (self.inheritedRowHeight != UITableViewAutomaticDimension)
        {
            return self.inheritedRowHeight
        }
    
        let height = self.inherited({ $0?.estimatedRowHeight })
        
        return height ?? UITableViewAutomaticDimension
    }()
    
    internal lazy var inheritedNib : UINib? = {
        let nib = self.inherited({ $0?.nib })
        
        return nib
    }()
    
    
    //MARK: UITableView related delegate methods
    
    func tableView(willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath)
    {
        if inheritedTintChevronDisclosures == true {
            for case let button as UIButton in cell.subviews {
                let image = button.backgroundImage(for: UIControlState())?.withRenderingMode(.alwaysTemplate)
                button.setBackgroundImage(image, for: UIControlState())
            }
            
            for disclosure in cell.subviews {
                if (NSStringFromClass(type(of: disclosure)) == "UITableViewCellDetailDisclosureView") {
                    for case let imageView as UIImageView in disclosure.subviews {
                        let image = imageView.image?.withRenderingMode(.alwaysTemplate)
                        imageView.image = image
                    }
                }
            }
        }
        
        self.inheritedStyleBeforeDisplayHandler?(self,cell)
    }
    
    func tableViewHeightForRow() -> CGFloat
    {
        if self.inheritedHidden() == true {
            return 0
        }
        
        return self.inheritedRowHeight
    }
    
    func tableViewEstimatedHeightForRow() -> CGFloat {
        let estimatedHeight = self.inheritedEstimatedRowHeight
        
        if (estimatedHeight == UITableViewAutomaticDimension && self.inheritedNib != nil)
        {
            print("Warning: when using a nib, you should set estimatedRowHeight or rowHeight.\nCurrently using UITableViewAutomaticDimension for indexPath:\(String(describing: self.lastIndexPath))")
        }
        
        return estimatedHeight
    }
    
    func tableViewDidSelectRow()
    {
        self.inheritedClickHandler()?(self)
        
        if (self.inheritedAutoDeselect())
        {
            self.table.deselectRow(at: self.lastIndexPath, animated: true)
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
