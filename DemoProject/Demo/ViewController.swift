//
//  ViewController.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 27/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var table: HSTableView!
    @IBOutlet weak var navItem: UINavigationItem!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        populateTable()
        
        
        navItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populateTable()
    {
        self.table.startDataUpdate()
        self.table.allowsSelectionDuringEditing=true
        
        
        var section=self.table.addSection("Regular cells")
        section.sectionInfo.titleColor=UIColor.blueColor()
        section.sectionInfo.subtitleColor=UIColor.orangeColor()
        
        
        var row=HSTVRowInfo(title:"Reload Table",subtitle: "Number of rows in first section is somewhat random")
        row.leftImageName="713-refresh-1"
        row.clickHandler = {
            [unowned self] (row) in
            self.populateTable()
        };
        table+=row
        
        let numberOfRandoms=random()%6
        for i in 1...(2+numberOfRandoms) {
            row=HSTVRowInfo(title:"Section One: \(i)")
            if (i%2==0)
            {
                row.subtitle="subtitle \(NSDate.init())"
                row.clickHandler = {row in
                    print("Regular cell section click handler, \(i)")
                };
            }
            table+=row
        }
        
    
        
        
        self.table.addSection("Editable")
        row = HSTVRowInfo(title: "Delete Me")
        row.editingStyle=UITableViewCellEditingStyle.Delete
        row.deleteHandler=row.simpleDeleteHandler
        table += row
        
        self.table.addSection("Linked to default")
        row = HSTVRowInfo(title: "Linked to NSUserDefault TestDefault")
        row.linkTo("TestDefault", trueSubtitle: "TestDefault is true", falseSubtitle: "TestDefault is false")
        table += row
        
        row = HSTVRowInfo(title: "Linked to NSUserDefault TestOppositeDefault")
        row.linkTo("TestOppositeDefault", trueSubtitle: "TestDefault is true", falseSubtitle: "TestDefault is false", checkmarkShowsForFalse: true)
        table += row
        
        
        section=self.table.addSection("Accessory views")
        section.sectionInfo.subtitle=""
        
        row = HSTVRowInfo(title:"Chevron")
        row.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        row.leftImageName="04-squiggle"
        row.tintColor=UIColor.orangeColor()
        row.tintChevronDisclosures = true
        table += row
        
        
        row = HSTVRowInfo(title:"Chevron")
        row.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        row.tintColor=UIColor.orangeColor()
        table += row
        
        
        row = HSTVRowInfo(title:"Disclosure")
        row.accessoryType = UITableViewCellAccessoryType.DetailDisclosureButton
        row.leftImageName="04-squiggle"
        row.leftImageColor=UIColor.purpleColor()
        row.tintColor=UIColor.orangeColor()
        row.tintChevronDisclosures = true
        row.accessoryClickHandler = {
            row in
            print ("Disclosure accessory clicked")
        }
        table += row
        
        row = HSTVRowInfo(title:"Checkmark")
        row.accessoryType = UITableViewCellAccessoryType.Checkmark
        table += row
        
        row = HSTVRowInfo(title:"Info")
        row.accessoryType = UITableViewCellAccessoryType.DetailButton
        row.accessoryClickHandler = {
            row in
            print ("Info accessory clicked")
        }
        table += row
        
        
        section = self.table.addSection("Custom Xib")
        section.sectionInfo.subtitle="Section Override"
        let myNib = UINib(nibName: "MyTableViewCell", bundle: nil)
        section.sectionInfo.nib=myNib
        section.sectionInfo.estimatedRowHeight=150
        
        for i in 1...2 {
            let row=HSTVRowInfo(title:"One: \(i)")
            if (i%2==0)
            {
                row.subtitle="subtitle"
            }
            self.table.addRow(row)
        }
        
        section=self.table.addSection(nil)
        
        for i in 1...2 {
            let row=HSTVRowInfo(title:"Section with no header \(i)")
            self.table.addRow(row)
        }
        section.sectionInfo.styleAfterCreateHandler = {
            row,cell in
            
            //os caches imageNamed results
            var image=UIImage(named:"tableRowBackground.png")
            image=image?.stretchableImageWithLeftCapWidth(30, topCapHeight: 2)
            
            cell.backgroundView=UIImageView.init(image: image)
            
            cell.textLabel?.textColor=UIColor.whiteColor()
            cell.detailTextLabel?.textColor=UIColor.whiteColor()
        }
        section.sectionInfo.reuseIdentifier="orange"
        
        
        //Table level overrides
        
        self.table.tableInfo.subtitle="Table override"
        self.table.tableInfo.clickHandler = {row in
            print("Table handler click handler, \(row.lastIndexPath.section),\(row.lastIndexPath.row)")
            row.subtitle="clicked at \(NSDate.init())"
            row.redrawCell(UITableViewRowAnimation.Fade)
        };
        
        self.table.applyDataUpdate()
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.table.setEditing(editing, animated: animated)
    }
    
    
}

