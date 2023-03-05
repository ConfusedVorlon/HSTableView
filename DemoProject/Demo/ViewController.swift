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

        self.view.backgroundColor = UIColor.darkGray

        populateTable()

        navItem.rightBarButtonItem = self.editButtonItem

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func populateTable() {
        table.startDataUpdate()
        table.allowsSelectionDuringEditing=true

        // Provide defaults for all rows in the table
        // This will apply unless a value is set at a more specific level (section or row)
        table.info.subtitleColor = UIColor.lightGray
        table.info.backgroundColor = .darkGray
        table.info.titleColor = .white
        table.info.leftImageColor = .white

        table.info.subtitle="Table default subtitle"
        table.info.clickHandler = {row in
            // Default click handler prints the index path, updates the subtitle and redraws the row
            print("Table handler click: \(String(describing: row.lastIndexPath))")
            row.subtitle="clicked at \(Date.init())"
            row.redrawCell(UITableView.RowAnimation.fade)
        }

        // Section
        // Add a section with a simple title
        //
        var section=self.table.addSection("Regular cells")
        // Provide some defaults for items in this section
        section.info.subtitleColor=UIColor.orange

        // First row has a simple click handler that reloads the table data
        // The number or rows is random - so you can see the effect of the reload
        var row=HSTVRowInfo(title: "Reload Table", subtitle: "Number of rows in first section is somewhat random")
        row.leftImageName="713-refresh-1"
        row.leftImageColor = .orange
        row.clickHandler = {
            [unowned self] (_) in
            self.populateTable()
        }
        table += row

        let numberOfRandoms=arc4random_uniform(6)
        // Random number of rows with the title 'Section One'
        // Odd rows get their subtitle from the table
        // Even rows have their own subtitle
        for i in 1...(2+numberOfRandoms) {
            row=HSTVRowInfo(title: "Section One: \(i)")
            if i%2==0 {
                row.subtitle="subtitle \(Date.init())"
                row.clickHandler = {_ in
                    print("Regular cell section click handler, \(i)")
                }
            }
            table += row
        }

        // Section
        // Simple swipe to delete row
        //
        self.table.addSection("Editable")
        row = HSTVRowInfo(title: "Swipe to delete")
        row.editingStyle=UITableViewCell.EditingStyle.delete
        row.deleteHandler=row.simpleDeleteHandler
        table += row

        // Section
        // Row value is linked to the user default 'TestDefault'
        //
        self.table.addSection("Linked to default")
        row = HSTVRowInfo(title: "Linked to UserDefault 'TestDefault'")
        row.handleCheckmark(userDefault: "TestDefault",
                            checkedSubtitle: "Checked (user default true)",
                            uncheckedSubtitle: "UnChecked (user default false)")
        table += row

        // Row value is linked to the user default 'TestDefault', but checkmark shows when value is false
        row = HSTVRowInfo(title: "Linked to UserDefault 'TestOppositeDefault'")
        row.handleCheckmark(userDefault: "TestOppositeDefault",
                            checkedSubtitle: "Checked (user default false)",
                            uncheckedSubtitle: "UnChecked (user default true)",
                            checkmarkShowsForFalse: true)
        table += row

        // Section
        // Various accessory views
        // (including coloured disclosure indicators)
        section=self.table.addSection("Accessory views")
        section.info.subtitle=""

        row = HSTVRowInfo(title: "Chevron")
        row.accessoryType = .disclosureIndicator
        row.leftImageName="04-squiggle"
        row.tintColor=UIColor.orange
        row.tintChevronDisclosures = true
        table += row

        row = HSTVRowInfo(title: "Chevron")
        row.accessoryType = .disclosureIndicator
        row.tintColor=UIColor.orange
        table += row

        row = HSTVRowInfo(title: "Disclosure")
        row.accessoryType = .detailDisclosureButton
        row.leftImageName="04-squiggle"
        row.leftImageColor=UIColor.purple
        row.tintColor=UIColor.orange
        row.tintChevronDisclosures = true
        row.accessoryClickHandler = {
            _ in
            print("Disclosure accessory clicked")
        }
        table += row

        row = HSTVRowInfo(title: "Checkmark")
        row.accessoryType = .checkmark
        table += row

        row = HSTVRowInfo(title: "Info")
        row.accessoryType = .detailButton
        row.accessoryClickHandler = {
            _ in
            print("Info accessory clicked")
        }
        table += row

//         Section
//         Row loaded from prototype cell
        section = self.table.addSection("Cell Prototype")
        section.info.reuseIdentifier = "ProtoCell"

        for i in 1...2 {
            let row=HSTVRowInfo(title: "One: \(i)")
            if i%2==0 {
                row.subtitle="subtitle"
            }
            table += row
        }

        // Section
        // Row loaded from custom xib
        //
        section = self.table.addSection("Custom Xib")
        section.info.subtitle="Section Override"
        let myNib = UINib(nibName: "MyTableViewCell", bundle: nil)
        section.info.nib=myNib
        section.info.estimatedRowHeight=150

        for i in 1...2 {
            let row=HSTVRowInfo(title: "One: \(i)")
            if i%2==0 {
                row.subtitle="subtitle"
            }
            table += row
        }

        // Section
        // Nil title for section makes the header invisibile
        // styleAfterCreate handler used to set custom background and override label colours
        //
        section=self.table.addSection(nil)
        for i in 1...2 {
            let row=HSTVRowInfo(title: "Section with no header \(i)")
            table += row
        }

        // style after create handler in this section customises the row in code
        // setting a reuseTag makes sure that this cell is not re-used elsewhere
        section.info.styleAfterCreateHandler = {
            _, cell in

            // os caches imageNamed results
            var image=UIImage(named: "tableRowBackground.png")
            image=image?.stretchableImage(withLeftCapWidth: 30, topCapHeight: 2)

            cell.backgroundView=UIImageView.init(image: image)

            cell.textLabel?.textColor=UIColor.white
            cell.detailTextLabel?.textColor=UIColor.white
        }
        section.info.reuseTag="orange"

        self.table.applyDataUpdate()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.table.setEditing(editing, animated: animated)
    }

}

extension ViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        table.filter { (row) -> Bool in
            if searchText.count == 0 {
                return true
            }
            return row.title?.lowercased().contains(searchText.lowercased()) ?? false
        }
    }

}
