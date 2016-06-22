//
//  MyTableViewCell.swift
//  SwiftExperiment
//
//  Created by Rob Jonson on 31/05/2016.
//  Copyright © 2016 HobbyistSoftware. All rights reserved.
//

import UIKit

class MyTableViewCell: UITableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
//    @IBOutlet var textLabel: UILabel!
//    @IBOutlet var detailTextLabel: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()

        //self.textLabel?.hidden=true

        self.contentView.backgroundColor=UIColor.redColor()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    override var textLabel: UILabel?
    {
        return self.label1;
    }
    
    override var detailTextLabel: UILabel?
    {
        return self.label2;
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
