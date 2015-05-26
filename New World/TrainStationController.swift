//
//  TrainStationController.swift
//  New World
//
//  Created by Huw on 2015-05-24.
//  Copyright (c) 2015 Huw. All rights reserved.
//

import Cocoa
import AVKit
import Foundation

class TrainStationController: MoviewController {

    @IBOutlet weak var player: AVPlayerView!
    @IBOutlet weak var locationLabel: NSButtonCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let primary = NSColor(
            red: 256/256,
            green: 221/256,
            blue: 175/256,
            alpha: 1
        )
        let attrs = [
            NSForegroundColorAttributeName:primary,
            NSFontAttributeName:NSFont(
                name: "Uni Sans Heavy CAPS",
                size: 71
            )!
        ]
        
        locationLabel.attributedTitle = NSAttributedString(
            string: "LOCATION",
            attributes: attrs
        )
        
        self.playVideo(player, fileName: "trainstation")
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        player.player.pause()
    }
    
    @IBAction func backButton1(sender: AnyObject) {
        self.dismissController(nil)
    }
    
    @IBAction func backButton2(sender: AnyObject) {
        self.dismissController(nil)
    }
}
