//
//  BankController.swift
//  New World
//
//  Created by Huw on 2015-05-19.
//  Copyright (c) 2015 Huw. All rights reserved.
//

import Cocoa
import AVKit

class BankController: MoviewController {
    
    @IBOutlet weak var player: AVPlayerView!
    @IBOutlet weak var locationLabel: NSButton!
    
    var locationName: String = "Location"
    var previous: CityScreenController = CityScreenController()
    
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
        
        var location = self.stores[locationName]["name"].string!
        locationLabel.attributedTitle = NSAttributedString(
            string: location,
            attributes: attrs
        )
        
        self.playVideo(player, fileName: "utopolis")
    }

    @IBAction func backButton1(sender: AnyObject) {
        self.previous.user = self.user
        self.dismissController(nil)
    }
    
    @IBAction func backButton2(sender: AnyObject) {
        self.previous.user = self.user
        self.dismissController(nil)
    }
    
}
