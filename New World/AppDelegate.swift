//
//  AppDelegate.swift
//  New World
//
//  Created by Huw on 2015-05-06.
//  Copyright (c) 2015 Huw. All rights reserved.
//

import Cocoa
import QuartzCore
import AVFoundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillTerminate(aNotification: NSNotification) {
        let window = NSApplication.sharedApplication().keyWindow
        let view = window?.contentViewController as! MoviewController
        view.user.rawString()?.writeToFile(NSBundle.mainBundle().pathForResource("user_save", ofType: "json")!, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
        view.stores.rawString()?.writeToFile(NSBundle.mainBundle().pathForResource("stores_save", ofType: "json")!, atomically: false, encoding: NSUTF8StringEncoding, error: nil)
    }
}

