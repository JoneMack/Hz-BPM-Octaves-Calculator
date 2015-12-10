//
//  Extensions.swift
//  Octaves
//
//  Created by 262Hz on 7/5/15.
//  Copyright (c) 2015 262Hz. All rights reserved.
//

import UIKit

extension UITextField {
    // Removes typical functionality for copy, paste, and select all. That functionality is not necessary for this app, and it is more of a distraction than it is useful.
    public override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            UIMenuController.sharedMenuController().setMenuVisible(false, animated: false)
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

extension UIViewAnimationCurve {
    func toOptions() -> UIViewAnimationOptions {
        switch self {
        case UIViewAnimationCurve.EaseInOut:
            return UIViewAnimationOptions.CurveEaseInOut
        case UIViewAnimationCurve.EaseIn:
            return UIViewAnimationOptions.CurveEaseIn
        case UIViewAnimationCurve.EaseOut:
            return UIViewAnimationOptions.CurveEaseOut
        case UIViewAnimationCurve.Linear:
            return UIViewAnimationOptions.CurveLinear
        }
    }
}

extension Double {
    func string() -> String {
        return String(format: "%.02f", arguments: [self])
    }
}