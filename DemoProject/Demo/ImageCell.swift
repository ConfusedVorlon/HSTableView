//
//  ImageCell.swift
//  HSTableViewDemo
//
//  Created by Rob Jonson on 30/04/2018.
//  Copyright © 2018 HobbyistSoftware. All rights reserved.
//


import UIKit

class ImageViewCell: UITableViewCell {

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!

    override var textLabel: UILabel?
    {
        return self.label1;
    }
    
    override var detailTextLabel: UILabel?
    {
        return self.label2;
    }

    
}
