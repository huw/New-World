//
//  CityScreenController.swift
//  New World
//
//  Created by Huw on 2015-05-19.
//  Copyright (c) 2015 Huw. All rights reserved.
//

import Cocoa
import AVKit

class CityScreenController: MoviewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var sellTableView: NSTableView!
    @IBOutlet weak var player: AVPlayerView!
    @IBOutlet weak var storeName: NSTextField!
    @IBOutlet weak var storeLocation: NSTextField!
    @IBOutlet weak var location: NSTextField!
    @IBOutlet weak var cashOnHand: NSTextField!
    @IBOutlet weak var cashInLoans: NSTextField!
    @IBOutlet weak var cashInBank: NSTextField!
    
    var locationName: String = "steamershill"
    var buyValues = [Int]()
    var sellValues = [Int]()
    
    override func viewDidAppear() {
        super.viewDidAppear()
        changeLocation()
    }
    
    // Pause the video to save CPU when we leave the view
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        player.player.pause()
        
        let next = segue.destinationController as! MoviewController
        next.stores = self.stores
        next.user = self.user
        
        // Do stuff specific to the classes (these ones have a specific `locationName` property)
        if segue.destinationController is TrainStationController {
            let destination = segue.destinationController as! TrainStationController
            destination.locationName = self.locationName
        } else if segue.destinationController is BankController {
            let destination = segue.destinationController as! BankController
            destination.locationName = self.locationName
            destination.previous = self
        }
    }
    
    func changeLocation() {
        // Play the video for this location
        self.playVideo(player, fileName: locationName)
        
        reloadArrays()
        
        // Set the table view's delegate and data source
        tableView.setDataSource(self)
        tableView.setDelegate(self)
        tableView.reloadData()
        
        sellTableView.setDataSource(self)
        sellTableView.setDelegate(self)
        sellTableView.reloadData()
        
        // Set the values of labels
        storeName.stringValue = stores[locationName]["storeName"].stringValue
        storeLocation.stringValue = stores[locationName]["storeLocation"].stringValue
        location.stringValue = stores[locationName]["name"].stringValue
        
        reloadCash()
        cashInBank.stringValue = String(stringInterpolationSegment: user["bankbalance"].double!) + " in bank"
        let loanBalance = user["loans"]["friendly"].double! + user["loans"]["standard"].double! + user["loans"]["super"].double!
        cashInLoans.stringValue = String(stringInterpolationSegment: loanBalance) + " owed"
    }
    
    func reloadArrays() {
        for i in self.stores[locationName]["inventory"] {
            buyValues.append(0)
        }
        for i in self.user["inventory"] {
            sellValues.append(0)
        }
    }
    
    func reloadCash() {
        user["balance"] = JSON(round(user["balance"].double! * 100) / 100)
        cashOnHand.stringValue = String(stringInterpolationSegment: user["balance"].double!) + " with me"
    }
    
    // I'm so sorry I had to use this. I really didn't want to, but time constraints -_-
    func errorBox(message: String, explanation: String = "") {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = explanation
        alert.addButtonWithTitle("OK")
        alert.runModal()
    }
    
    @IBAction func addItem(sender: AnyObject) {
        let row = tableView.rowForView(sender.superview!!)
        let itemData = self.stores[self.locationName]["inventory"][row]
        let cash = itemData["price"].double! * Double(buyValues[row])
        
        // Only if there's enough stock to sell to the user, and they have the cash
        if itemData["quantity"].int! >= buyValues[row] && buyValues[row] > 0 && user["balance"].double! >= cash {
            
            var prev = -1
            var inventory = self.user["inventory"].array!
            
            for (i, item) in enumerate(inventory) {
                if item["name"].string! == itemData["name"].string! {
                    prev = i
                }
            }
            
            if prev == -1 {
                // Build the new item into JSON, and then append it to the inventory array
                var newItem = JSON(["name": itemData["name"].string!, "quantity": buyValues[row], "price": itemData["price"].double!])
                inventory.append(newItem)
                self.user["inventory"] = JSON(inventory)
                
                reloadArrays()
            } else {
                let quantity = self.user["inventory"][prev]["quantity"].intValue
                self.user["inventory"][prev]["quantity"] = JSON(quantity + buyValues[row])
            }
            
            // Remove cash ;(
            self.user["balance"] = JSON(self.user["balance"].double! - cash)
            reloadCash()
            
            // Remove the item from inventory
            // Even if the item is at zero, we're still going to display it because stores always stock the same items upon successful revisits
            let quantity = self.stores[self.locationName]["inventory"][row]["quantity"].intValue
            self.stores[self.locationName]["inventory"][row]["quantity"] = JSON(quantity - buyValues[row])
            
            tableView.reloadData()
            sellTableView.reloadData()
        } else if itemData["quantity"].int! < buyValues[row] {
            errorBox("There isn't this much to buy!", explanation: "The amount you've entered is bigger than the amount in the store!")
        } else if user["balance"].double! < cash {
            errorBox("You don't have enough money to buy this!", explanation: "INCREASE FUNDS")
        }

    }
    
    @IBAction func buyChanged(sender: AnyObject) {
        // Only do this if the number is valid, and also avoid that really weird Cocoa error
        if let button = sender.superview! {
            let row = tableView.rowForView(button)
            if row != -1 {
                if let value = sender.integerValue {
                    if value > 0 {
                        buyValues[row] = sender.integerValue!
                    } else {
                        errorBox("You entered a number which can't be sold", explanation: "Please enter a number that's bigger than 0")
                    }
                } else {
                    errorBox("You entered a number which can't be sold", explanation: "Please enter a proper number")
                }
            } else {
                errorBox("Please click outside the input box first", explanation: "Because of Cocoa, you have to click outside the highlighted box before clicking on the buy button")
            }
        }
    }
    
    @IBAction func removeItem(sender: AnyObject) {
        let row = sellTableView.rowForView(sender.superview!!)
        let itemData = self.user["inventory"][row]
        let cash = itemData["price"].double! * Double(sellValues[row])
        
        // Only if there's enough stock to sell to the user
        if itemData["quantity"].int! >= sellValues[row] && sellValues[row] > 0{
            
            var prev = -1
            var inventory = self.stores[self.locationName]["inventory"].array!
            
            for (i, item) in enumerate(inventory) {
                if item["name"].string! == itemData["name"].string! {
                    prev = i
                }
            }
            
            if prev == -1 {
                // Build the new item into JSON, and then append it to the inventory array
                var newItem = JSON(["name": itemData["name"].string!, "quantity": sellValues[row], "price": itemData["price"].double!])
                inventory.append(newItem)
                self.stores[self.locationName]["inventory"] = JSON(inventory)
                
                reloadArrays()
            } else {
                let quantity = self.stores[self.locationName]["inventory"][prev]["quantity"].intValue
                self.stores[self.locationName]["inventory"][prev]["quantity"] = JSON(quantity + sellValues[row])
            }
            
            // Add cash!
            self.user["balance"] = JSON(self.user["balance"].double! + cash)
            reloadCash()
            
            // Remove the item from inventory
            // If it's at zero, remove it completely
            let quantity = self.user["inventory"][row]["quantity"].intValue
            
            if quantity - sellValues[row] <= 0 {
                var userInventory = self.user["inventory"].array!
                userInventory.removeAtIndex(row)
                self.user["inventory"] = JSON(userInventory)
            } else {
                self.user["inventory"][row]["quantity"] = JSON(quantity - sellValues[row])
            }
            
            tableView.reloadData()
            sellTableView.reloadData()
        } else if itemData["quantity"].int! < sellValues[row] {
            errorBox("There isn't this much to sell!", explanation: "You don't have enough of this item in your inventory!")
        }
    }
    
    @IBAction func sellChanged(sender: AnyObject) {
        if let field = sender.superview! {
            let row = sellTableView.rowForView(field)
            if row != -1 {
                if let value = sender.integerValue {
                    if value > 0 {
                        sellValues[row] = sender.integerValue!
                    } else {
                        errorBox("You entered a number which can't be sold", explanation: "Please enter a number that's bigger than 0")
                    }
                } else {
                    errorBox("You entered a number which can't be sold", explanation: "Please enter a proper number")
                }
            } else {
                errorBox("Please click outside the input box first", explanation: "Because of Cocoa, you have to click outside the highlighted box before clicking on the sell button")
            }
        }
    }
}

extension CityScreenController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let identifier = tableView.identifier!
        if identifier == "Buy Table" {
            return self.stores[locationName]["inventory"].count
        } else if identifier == "Sell Table" {
            return self.user["inventory"].count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        let tableIdentifier = tableView.identifier!
        var cellView: NSTableCellView = tableView.makeViewWithIdentifier(identifier, owner: self) as! NSTableCellView
        
        // This section controls the buy table
        if tableIdentifier == "Buy Table" {
            let itemData = self.stores[locationName]["inventory"][row]
            
            // Set the data for each column to the correct strings from the store data
            if identifier == "ItemName" {
                cellView.textField!.stringValue = itemData["name"].string!
            } else if identifier == "ItemQuantity" {
                cellView.textField!.stringValue = String(itemData["quantity"].int!)
            } else if identifier == "ItemPrice" {
                cellView.textField!.stringValue = "$" + String(stringInterpolationSegment: itemData["price"].double!)
            }
        // This section controls the sell table
        } else if tableIdentifier == "Sell Table" {
            let itemData = self.user["inventory"][row]
            
            if identifier == "ItemName" {
                // Combine the quantity and item name
                var data = String(itemData["quantity"].int!) + "x " + itemData["name"].string!
                cellView.textField!.stringValue = data
            } else if identifier == "ItemPrice" {
                cellView.textField!.stringValue = String(stringInterpolationSegment: itemData["price"].double!)
            }
        }
        
        return cellView
    }
}

extension CityScreenController: NSTableViewDelegate {
}