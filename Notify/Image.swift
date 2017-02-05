//
//  Image.swift
//  Notify
//
//  Created by Andrew Sowers on 2/10/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

func imageWithSolidColor(_ color: UIColor, size: CGSize = CGSize(width: 1.0, height: 1.0)) -> UIImage {
    let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    color.setFill()
    UIRectFill(rect)
    let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return image
}
