//
//  Helper.swift
//  SampleProjectSwift
//
//  Created by Gaurang Patel on 01/02/20.
//  Copyright © 2020 POLLFISH. All rights reserved.
//

import Foundation
import UIKit

class Helper: NSObject {
    
    @objc static func getTopViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        var controller = controller
        
        if (controller == nil) {
            
            controller = UIApplication.shared.windows.last!.rootViewController!
        }
        
        if let navigationController = controller as? UINavigationController {
            return getTopViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return getTopViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return getTopViewController(controller: presented)
        }
        return controller
    }
    
    @objc static func createUIActivityIndicatorView() -> UIActivityIndicatorView {
        
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        indicator.color = .orange

        return indicator
    }
    
    @objc static func createUILabel(frame: CGRect, font: UIFont, bgColor: UIColor, txtColor: UIColor) -> UILabel {

        let lbl = UILabel(frame: frame)
        lbl.numberOfLines = 0
        lbl.font = font
        lbl.backgroundColor = bgColor
        lbl.textColor = txtColor
        lbl.textAlignment = .center
        
        return lbl
    }
}
