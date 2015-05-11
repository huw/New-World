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
        
        if let thisWindow = self.window {
            thisWindow.toggleFullScreen(nil)
            thisWindow.standardWindowButton(NSWindowButton.ZoomButton)!.hidden = true
            thisWindow.standardWindowButton(NSWindowButton.MiniaturizeButton)!.hidden = true
        }
    }

}
