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
    @IBOutlet weak var owedLabel: NSTextField!
    
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
        
        self.locationName = self.user["location"].string!
        
        var location = self.stores[locationName]["name"].string!
        locationLabel.attributedTitle = NSAttributedString(
            string: location,
            attributes: attrs
        )
        
        self.playVideo(player, fileName: "utopolis")
        
        // Labels
        interestLabel.stringValue = "Interest Rate: " + String(stringInterpolationSegment: self.user["rate"].double!) + "%"
        friendlyLabel.stringValue = "Friendly™ Loan Rate: " + String(stringInterpolationSegment: self.user["rate"].double! / 2) + "%"
        standardLabel.stringValue = "Standard Loan Rate: " + String(stringInterpolationSegment: self.user["rate"].double!) + "%"
        superLabel.stringValue = "Super Loan Rate: " + String(stringInterpolationSegment: self.user["rate"].double! * 2) + "%"
        
        reloadLabels()
    }
    
    func reloadLabels() {
        balanceLabel.stringValue = "Balance: $" + String(stringInterpolationSegment: self.user["bankBalance"].double!)
        owedLabel.stringValue = "Owed: $" + String(stringInterpolationSegment: self.user["loans"]["friendly"].double! + self.user["loans"]["standard"].double! + self.user["loans"]["super"].double!)
    }

    func takeLoan(type: String) {
        let amount = borrowField.doubleValue
        
        var bound: Double = 999999999
        if type == "friendly" {
            bound = 1000
        } else if type == "standard" {
            bound = 50000
        }
        
        if 0 < amount && amount + self.user["loans"][type].double! <= bound {
            self.user["loans"][type] = JSON(self.user["loans"][type].double! + amount)
            self.user["bankBalance"] = JSON(self.user["bankBalance"].double! + amount)
            reloadLabels()
        } else if amount <= 0 {
            errorBox("This amount isn't a number", explanation: "Please put an actual number in the box")
        } else if amount + self.user["loans"][type].double! > bound {
            errorBox("This amount is too large for this loan!", explanation: "Please pick a more suitable loan. You can only borrow " + String(stringInterpolationSegment: bound - self.user["loans"][type].double!) + " more on this loan.")
        }
    }
    
    @IBAction func backButton1(sender: AnyObject) {
        self.previous.user = self.user
        self.previous.reloadCash()
        self.dismissController(nil)
    }
    
    @IBAction func backButton2(sender: AnyObject) {
        self.previous.user = self.user
        self.previous.reloadCash()
        self.dismissController(nil)
    }
    
    @IBAction func friendlyButton(sender: AnyObject) {
        takeLoan("friendly")
    }
    @IBAction func standardButton(sender: AnyObject) {
        takeLoan("standard")
    }
    @IBAction func superButton(sender: AnyObject) {
        takeLoan("super")
    }
    
    @IBAction func depositButton(sender: AnyObject) {
        var amount = balanceField.doubleValue
        if amount <= self.user["balance"].double! && amount > 0 {
            
            let balance = self.user["balance"].double!
            let bankBalance = self.user["bankBalance"].double!
            
            let friendly = self.user["loans"]["friendly"].double!
            let standard = self.user["loans"]["standard"].double!
            let superLoan = self.user["loans"]["friendly"].double!
            let owed = friendly + standard + superLoan
            
            // Remove what we're depositing from our hands
            self.user["balance"] = JSON(balance - amount)
            
            // Repayment necessary
            if owed >= amount {
                
                // Some loans get repayed (/partially)
                var left = amount
                
                for loan in ["friendly", "standard", "super"] {
                    let value = self.user["loans"][loan].double!
                    
                    // All of this type is repayed
                    if left >= value {
                        self.user["loans"][loan] = JSON(0)
                        left -= value
                    } else { // We stop at this iteration (kinda)
                        self.user["loans"][loan] = JSON(value - left)
                        left = 0
                        break
                    }
                }
                
                amount = 0
            } else if owed > 0 { // All loans get completely repaid
                amount -= owed
                
                self.user["loans"]["friendly"] = JSON(0)
                self.user["loans"]["standard"] = JSON(0)
                self.user["loans"]["super"] = JSON(0)
            }
            
            // Add what's left to our balance
            self.user["bankBalance"] = JSON(bankBalance + amount)
            
            reloadLabels()
        } else if amount <= 0 {
            errorBox("This amount is invalid", explanation: "Please enter a number that is greater than 0")
        } else if amount > self.user["balance"].double! {
            errorBox("You can't deposit this much", explanation: "You don't have enough money on hand to deposit")
        }
    }
    @IBAction func withdrawButton(sender: AnyObject) {
        let amount = balanceField.doubleValue
        if amount <= self.user["bankBalance"].double! && amount > 0 {
            self.user["balance"] = JSON(self.user["balance"].double! + amount)
            self.user["bankBalance"] = JSON(self.user["bankBalance"].double! - amount)
            reloadLabels()
        } else if amount <= 0 {
            errorBox("This amount is invalid", explanation: "Please enter a number that is greater than 0")
        } else if amount > self.user["bankBalance"].double! {
            errorBox("You can't withdraw this much", explanation: "You don't have this much money in the bank to withdraw")
        }
    }}
