//
//  ImageMaterial.swift
//  showcase-app
//
//  Created by Tihomir Videnov on 7/24/16.
//  Copyright © 2016 Tihomir Videnov. All rights reserved.
//

import UIKit

class ImageMaterial: UIImageView {

    override func awakeFromNib() {
        
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
    }
    
}
