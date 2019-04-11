//
//  UIColor+.swift
//  SwiftTagView
//
//  Created by 洪 権 on 2019/03/28.
//  Copyright © 2019 洪 権. All rights reserved.
//

import UIKit

extension UIColor {
    func toImage()->UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(self.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
