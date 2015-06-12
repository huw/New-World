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
    @IBOutlet weak var destinationLabel: NSTextField!
    @IBOutlet weak var departButton: NSButton!
    
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
    var previousLocation: String = ""
    var destination: String = ""
    
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
        case "lavamountain":
            brokencreekButton.enabled = true
        case "brokencreek":
            steamershillButton.enabled = true
            lavamountainButton.enabled = true
            utopolisButton.enabled = true
            somethingButton.enabled = true
        case "something":
            bobsknuckleButton.enabled = true
            brokencreekButton.enabled = true
            utopolisButton.enabled = true
        case "bobsknuckle":
            utopolisButton.enabled = true
            somethingButton.enabled = true
            hellButton.enabled = true
        case "hell":
            treetopgullyButton.enabled = true
            bobsknuckleButton.enabled = true
        default: ()
        }
        
        // Block off the previous location (unless it's Broken Creek)
        switch previousLocation {
        case "treetopgully":
            treetopgullyButton.enabled = false
        case "steamershill":
            steamershillButton.enabled = false
        case "newnewtown":
            newnewtownButton.enabled = false
        case "utopolis":
            utopolisButton.enabled = false
        case "lavamountain":
            lavamountainButton.enabled = false
        case "something":
            somethingButton.enabled = false
        case "bobsknuckle":
            bobsknuckleButton.enabled = false
        case "hell":
            hellButton.enabled = false
        default: ()
        }
        
        // Don't block the user off into Lava Mountain, but don't always leave Broken Creek available
        if previousLocation == "brokencreek" && locationName != "lavamountain" {
            brokencreekButton.enabled = false
        }
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        player.player.pause()
        let next = segue.destinationController as! CityScreenController
        next.dismissController(nil)
        next.stores = self.stores
        next.user = self.user
        next.locationName = self.destination
        next.previousLocation = self.locationName
    }
    
    @IBAction func backButton1(sender: AnyObject) {
        self.dismissController(nil)
    }
    
    @IBAction func backButton2(sender: AnyObject) {
        self.dismissController(nil)
    }
    
    @IBAction func treetopgullyClick(sender: AnyObject) {
        setDest("treetopgully")
    }
    @IBAction func steamershillClick(sender: AnyObject) {
        setDest("steamershill")
    }
    @IBAction func newnewtownClick(sender: AnyObject) {
        setDest("newnewtown")
    }
    @IBAction func utopolisClick(sender: AnyObject) {
        setDest("utopolis")
    }
    @IBAction func lavamountainClick(sender: AnyObject) {
        setDest("lavamountain")
    }
    @IBAction func brokencreekClick(sender: AnyObject) {
        setDest("brokencreek")
    }
    @IBAction func somethingClick(sender: AnyObject) {
        setDest("something")
    }
    @IBAction func bobsknuckleClick(sender: AnyObject) {
        setDest("bobsknuckle")
    }
    @IBAction func hellClick(sender: AnyObject) {
        setDest("hell")
    }
    
    func setDest(destination: String) {
        self.destination = destination
        destinationLabel.stringValue = self.stores[destination]["name"].stringValue.capitalizedString
        
        // The depart button starts disabled so users don't go to an empty place
        if departButton.enabled == false {
            departButton.enabled = true
        }
    }
}
