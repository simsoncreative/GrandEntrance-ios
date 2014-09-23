//
//  RoundedButton.swift
//  GrandEntrance
//
//  Created by Alexander Simson on 2014-08-14.
//  Copyright (c) 2014 Simson Creative Solutions. All rights reserved.
//

import UIKit

class RoundedButton: UIButton
{
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderColor = UIColor.whiteColor().CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = self.frame.size.height/2.0;
    }
}
