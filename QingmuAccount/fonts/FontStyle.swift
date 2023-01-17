//
//  FontStyle.swift
//  QingmuAccount
//
//  Created by 周荥马 on 2022/12/6.
//

import Foundation
import SwiftUI
import UIKit

public extension UIFont {
    class func icomoonFont(ofSize: CGFloat) -> UIFont? {
        return UIFont(name: "icomoon", size: ofSize)
    }
}

public extension UIImage {
    convenience init?(text: IconFontEnum, fontSize: CGFloat, imageSize: CGSize = CGSize.zero, imageColor: UIColor = UIColor.black) {
        guard let icomoon = UIFont.icomoonFont(ofSize: fontSize) else {
            self.init()
            return nil
        }
        var imageRect = CGRect(origin: CGPoint.zero, size: imageSize)
        if __CGSizeEqualToSize(imageSize, CGSize.zero) {
            imageRect = CGRect(origin: CGPoint.zero, size: text.rawValue.size(withAttributes: [NSAttributedString.Key.font: icomoon]))
        }
        UIGraphicsBeginImageContextWithOptions(imageRect.size, false, UIScreen.main.scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        text.rawValue.draw(in: imageRect, withAttributes: [NSAttributedString.Key.font : icomoon, NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: imageColor])
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
