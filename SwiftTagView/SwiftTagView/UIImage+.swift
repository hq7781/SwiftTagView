//
//  UIImage+.swift
//  SwiftTagView
//
//  Created by 洪 権 on 2019/03/29.
//  Copyright © 2019 洪 権. All rights reserved.
//

import Foundation
extension UIImage {
    // resize image
    func resize(to:CGSize)->UIImage? {
        //UIGraphicsBeginImageContext(reSize)
        UIGraphicsBeginImageContextWithOptions(to,false,UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
        let reSizeImage:UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    func resize(width:CGFloat, height:CGFloat)->UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height),false,UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width:width, height:height))
        let reSizeImage:UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return reSizeImage
    }
}
