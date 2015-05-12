//
//  MainWindowController.swift
//  New World
//
//  Created by Huw on 2015-05-11.
//  Copyright (c) 2015 Huw. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        let screen = NSScreen.mainScreen()?.visibleFrame
        let width = screen!.width
        let height = screen!.height
        
        if let thisWindow = self.window {
            // Disable unwanted buttons
            thisWindow.standardWindowButton(NSWindowButton.ZoomButton)!.hidden = true
            thisWindow.standardWindowButton(NSWindowButton.MiniaturizeButton)!.hidden = true
            
            // Only make fullscreen if its below the size we want
            if width <= 1280 && height <= 800 {
                thisWindow.toggleFullScreen(nil)
            }
            
            // Make background black
            thisWindow.backgroundColor = NSColor.blackColor()
        }
    }

}
