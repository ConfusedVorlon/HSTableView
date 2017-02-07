# HSTableView

A better UITableView. Rows are managed by objects. Things happen with blocks.
Your whole table is declared up front with no need for delegates

The table view uses a responder chain approach to provide settings. Any setting can be set at the row level, the section level or the table level.

This allows simple configuration at the table level, and easy customisation at the row level.

Blocks are used for tap handlers, delete handlers, etc.

Default (coloured) accessories are supported

HSTableView is suitable for situations where there is a known finite number of rows (although the number can change).
It doesn’t support infinite scrolling tables (you’ll have to use delegates for that).


##Demo

![Demo table](https://raw.githubusercontent.com/ConfusedVorlon/HSTableView/master/Images/demo.png)

this function completely defines the example table

```swift
    func populateTable()
    {
        table.startDataUpdate()
        table.allowsSelectionDuringEditing=true
        // Provide defaults for all rows in the table
        // This will apply unless a value is set at a more specific level (section or row)
        table.info.subtitleColor = UIColor.lightGray
        table.info.subtitle="Table default subtitle"
        table.info.clickHandler = {row in
            print("Table handler click handler, \(row.lastIndexPath.section),\(row.lastIndexPath.row)")
            row.subtitle="clicked at \(Date.init())"
            row.redrawCell(UITableViewRowAnimation.fade)
        };
        
        // Add a section with a simple title
        var section=self.table.addSection("Regular cells")
        // Provide some defaults for items in this section
        section.info.titleColor=UIColor.blue
        section.info.subtitleColor=UIColor.orange
        
        //First row shows a simple click handler that reloads the table data
        var row=HSTVRowInfo(title:"Reload Table",subtitle: "Number of rows in first section is somewhat random")
        row.leftImageName="713-refresh-1"
        row.clickHandler = {
            [unowned self] (row) in
            self.populateTable()
        };
        table += row
        
        let numberOfRandoms=arc4random_uniform(6)
        //Random number of rows with the title 'Section One'
        //Odd rows get their subtitle from the table
        //Even rows have their own subtitle
        for i in 1...(2+numberOfRandoms) {
            row=HSTVRowInfo(title:"Section One: \(i)")
            if (i%2==0)
            {
                row.subtitle="subtitle \(Date.init())"
                row.clickHandler = {row in
                    print("Regular cell section click handler, \(i)")
                };
            }
            table += row
        }
  
        
        // Simple swipe to delete row
        self.table.addSection("Editable")
        row = HSTVRowInfo(title: "Swipe to delete")
        row.editingStyle=UITableViewCellEditingStyle.delete
        row.deleteHandler=row.simpleDeleteHandler
        table += row
        
        //Row value is linked to the user default 'TestDefault'
        self.table.addSection("Linked to default")
        row = HSTVRowInfo(title: "Linked to UserDefault 'TestDefault'")
        row.linkTo("TestDefault", trueSubtitle: "TestDefault is true", falseSubtitle: "TestDefault is false")
        table += row
        
        //Row value is linked to the user default 'TestDefault', but checkmark shows when value is false
        row = HSTVRowInfo(title: "Linked to UserDefault TestOppositeDefault")
        row.linkTo("TestOppositeDefault", trueSubtitle: "TestDefault is true", falseSubtitle: "TestDefault is false", checkmarkShowsForFalse: true)
        table += row
        
        //Various accessory views
        section=self.table.addSection("Accessory views")
        section.info.subtitle=""
        
        row = HSTVRowInfo(title:"Chevron")
        row.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        row.leftImageName="04-squiggle"
        row.tintColor=UIColor.orange
        row.tintChevronDisclosures = true
        table += row
        
        
        row = HSTVRowInfo(title:"Chevron")
        row.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        row.tintColor=UIColor.orange
        table += row
        
        
        row = HSTVRowInfo(title:"Disclosure")
        row.accessoryType = UITableViewCellAccessoryType.detailDisclosureButton
        row.leftImageName="04-squiggle"
        row.leftImageColor=UIColor.purple
        row.tintColor=UIColor.orange
        row.tintChevronDisclosures = true
        row.accessoryClickHandler = {
            row in
            print ("Disclosure accessory clicked")
        }
        table += row
        
        row = HSTVRowInfo(title:"Checkmark")
        row.accessoryType = UITableViewCellAccessoryType.checkmark
        table += row
        
        row = HSTVRowInfo(title:"Info")
        row.accessoryType = UITableViewCellAccessoryType.detailButton
        row.accessoryClickHandler = {
            row in
            print ("Info accessory clicked")
        }
        table += row
        
        //Row loaded from xib
        section = self.table.addSection("Custom Xib")
        section.info.subtitle="Section Override"
        let myNib = UINib(nibName: "MyTableViewCell", bundle: nil)
        section.info.nib=myNib
        section.info.estimatedRowHeight=150
        
        for i in 1...2 {
            let row=HSTVRowInfo(title:"One: \(i)")
            if (i%2==0)
            {
                row.subtitle="subtitle"
            }
            table += row
        }
        
        //Nil title for section makes the header invisibile
        section=self.table.addSection(nil)
        for i in 1...2 {
            let row=HSTVRowInfo(title:"Section with no header \(i)")
            table += row
        }
        
        //style after create handler in this section customises the row in code
        //setting a reuseIdentifier makes sure that this cell is not re-used elsewhere
        section.info.styleAfterCreateHandler = {
            row,cell in
            
            //os caches imageNamed results
            var image=UIImage(named:"tableRowBackground.png")
            image=image?.stretchableImage(withLeftCapWidth: 30, topCapHeight: 2)
            
            cell.backgroundView=UIImageView.init(image: image)
            
            cell.textLabel?.textColor=UIColor.white
            cell.detailTextLabel?.textColor=UIColor.white
        }
        section.info.reuseIdentifier="orange"
        
        
        self.table.applyDataUpdate()
    }
```




