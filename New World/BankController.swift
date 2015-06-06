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
    
    @IBOutlet weak var interestLabel: NSTextField!
    @IBOutlet weak var friendlyLabel: NSTextField!
    @IBOutlet weak var standardLabel: NSTextField!
    @IBOutlet weak var superLabel: NSTextField!
    @IBOutlet weak var balanceLabel: NSTextField!
    
    @IBOutlet weak var borrowField: NSTextField!
    @IBOutlet weak var balanceField: NSTextField!
    
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
        
        // Labels
        interestLabel.stringValue = "Interest Rate: " + String(stringInterpolationSegment: self.user["rate"].double!)
        friendlyLabel.stringValue = "Friendly™ Loan Rate: " + String(stringInterpolationSegment: self.user["rate"].double! / 2)
        standardLabel.stringValue = "Standard Loan Rate: " + String(stringInterpolationSegment: self.user["rate"].double!)
        superLabel.stringValue = "Super Loan Rate: " + String(stringInterpolationSegment: self.user["rate"].double! * 2)
        
        balanceLabel.stringValue = "Balance: " + String(stringInterpolationSegment: self.user["bankBalance"].double!)
    }

    @IBAction func backButton1(sender: AnyObject) {
        self.previous.user = self.user
        self.dismissController(nil)
    }
    
    @IBAction func backButton2(sender: AnyObject) {
        self.previous.user = self.user
        self.dismissController(nil)
    }
    
    @IBAction func friendlyButton(sender: AnyObject) {
    }
    @IBAction func standardButton(sender: AnyObject) {
    }
    @IBAction func superButton(sender: AnyObject) {
    }
    
    @IBAction func depositButton(sender: AnyObject) {
    }
    @IBAction func withdrawButton(sender: AnyObject) {
    }
}
