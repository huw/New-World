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
    
    @IBOutlet weak var walkButton: NSButton!
    @IBOutlet weak var trainButton: NSButton!
    
    var locationName: String = "Location"
    var previousLocation: String = ""
    var destination: String = ""
    var train = false
    
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
        
        self.locationName = self.user["location"].string!
        self.previousLocation = self.user["previousLocation"].string!

        var location = self.stores[locationName]["name"].string!
        locationLabel.attributedTitle = NSAttributedString(
            string: location,
            attributes: attrs
        )
        
        self.playVideo(player, fileName: "trainstation")
        
        resetBlips()
        blockPrevious()
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        player.player.pause()
        let next = segue.destinationController as! CityScreenController
        next.dismissController(nil)
        
        self.user["location"] = JSON(self.destination)
        self.user["previousLocation"] = JSON(self.locationName)
        
        // Deduct fare
        if train {
            self.user["balance"] = JSON(self.user["balance"].double! - 5)
        }
        
        next.stores = self.stores
        next.user = self.user
        next.events = self.events
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
    
    @IBAction func pickWalk(sender: AnyObject) {
        train = false
        trainButton.enabled = true
        trainButton.stringValue = "TAKE TRAIN ($5)"
        walkButton.enabled = false
        walkButton.stringValue = "WALKING"
        resetBlips()
        blockPrevious()
    }
    @IBAction func pickTrain(sender: AnyObject) {
        if self.user["balance"].double! >= 5 {
            train = true
            walkButton.enabled = true
            walkButton.stringValue = "WALK"
            trainButton.enabled = false
            trainButton.stringValue = "TAKING TRAIN"
            resetBlips()
            
            // Follow the coloured lines
            // Due to heavy congestion in Utopolis, you can only take the yellow line to Lava Mountain
            // A train isn't always convenient, and some people might slip up. Even better :)
            switch locationName {
            case "treetopgully":
                utopolisButton.enabled = true
            case "steamershill":
                treetopgullyButton.enabled = true
                newnewtownButton.enabled = true
                utopolisButton.enabled = true
                somethingButton.enabled = true
            case "utopolis":
                lavamountainButton.enabled = true
            case "newnewtown":
                steamershillButton.enabled = true
            case "lavamountain":
                brokencreekButton.enabled = true
                utopolisButton.enabled = true
            case "something":
                hellButton.enabled = true
                steamershillButton.enabled = true
            case "bobsknuckle":
                utopolisButton.enabled = true
                somethingButton.enabled = true
                hellButton.enabled = true
            default: ()
            }
            
            blockPrevious()
        } else {
            errorBox("You don't have the cash!", explanation: "You need at least $5 to board a train.")
        }
    }
    
    func setDest(destination: String) {
        self.destination = destination
        destinationLabel.stringValue = self.stores[destination]["name"].stringValue.capitalizedString
        
        if departButton.enabled == false {
            departButton.enabled = true
        }
    }
    
    func resetBlips() {
        // Turn off all buttons
        steamershillButton.enabled = false
        newnewtownButton.enabled = false
        hellButton.enabled = false
        treetopgullyButton.enabled = false
        brokencreekButton.enabled = false
        utopolisButton.enabled = false
        newnewtownButton.enabled = false
        somethingButton.enabled = false
        bobsknuckleButton.enabled = false
        lavamountainButton.enabled = false
        
        // Turn on the ones that will always be enabled for this location
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
    }
    
    func blockPrevious() {
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
}
