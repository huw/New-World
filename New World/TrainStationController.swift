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
    
    @IBOutlet weak var treetopgullyButton: NSButton!
    @IBOutlet weak var steamershillButton: NSButton!
    @IBOutlet weak var newnewtownButton: NSButton!
    @IBOutlet weak var utopolisButton: NSButton!
    @IBOutlet weak var brokencreekButton: NSButton!
    @IBOutlet weak var lavamountainButton: NSButton!
    @IBOutlet weak var somethingButton: NSButton!
    @IBOutlet weak var bobsknuckleButton: NSButton!
    @IBOutlet weak var hellButton: NSButton!
    
    var locationName: String = "Location"
    
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
        
        self.playVideo(player, fileName: "trainstation")
        
        switch locationName {
        case "treetopgully":
            steamershillButton.enabled = true
            newnewtownButton.enabled = true
            hellButton.enabled = true
        case "steamershill":
            treetopgullyButton.enabled = true
            brokencreekButton.enabled = true
        case "newnewtown":
            treetopgullyButton.enabled = true
            utopolisButton.enabled = true
        case "utopolis":
            newnewtownButton.enabled = true
            bobsknuckleButton.enabled = true
            somethingButton.enabled = true
            brokencreekButton.enabled = true
        case "brokencreek":
            steamershillButton.enabled = true
            lavamountainButton.enabled = true
            utopolisButton.enabled = true
            somethingButton.enabled = true
        case "lavamountain":
            brokencreekButton.enabled = true
        case "bobsknuckle":
            utopolisButton.enabled = true
            somethingButton.enabled = true
            hellButton.enabled = true
        case "hell":
            treetopgullyButton.enabled = true
            bobsknuckleButton.enabled = true
        default:
            true
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        self.dismissController(nil)
    }
    
    @IBAction func backButton1(sender: AnyObject) {
        self.dismissController(nil)
    }
    
    @IBAction func backButton2(sender: AnyObject) {
        self.dismissController(nil)
    }
}
