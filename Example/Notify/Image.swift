//
//  Image.swift
//  Notify
//
//  Created by Andrew Sowers on 2/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

func imageWithSolidColor(color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage {
    let rect = CGRectMake(0.0, 0.0, size.width, size.height)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image
}
