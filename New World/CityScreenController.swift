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
    
    @IBOutlet weak var headline: NSTextField!
    @IBOutlet weak var subtitle: NSTextField!
    
    var locationName: String = "steamershill"
    var previousLocation: String = ""
    var buyValues = [Int]()
    var sellValues = [Int]()
    
    var kingItems = ["Interesting Rock", "New Sportscar", "Turbo Engine", "Obsidian Knife", "Ambiguous Dress", "Treetop House", "Arty Painting", "Scholarship", "The Gay Agenda"]
    
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
        next.events = self.events
        
        // Do stuff specific to the classes (these ones have a specific `locationName` property)
        if segue.destinationController is TrainStationController {
            let destination = segue.destinationController as! TrainStationController
            destination.locationName = self.locationName
            destination.previousLocation = self.previousLocation
        } else if segue.destinationController is BankController {
            let destination = segue.destinationController as! BankController
            destination.locationName = self.locationName
            destination.previous = self
        }
    }
    
    func changeLocation() {
        // Play the video for this location
        self.playVideo(player, fileName: "utopolis")
        
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
        
        // Change the day (compound interest, etc)
        // Compound interest:
        var rate = round((self.user["rate"].double! + (Double(arc4random()) / 0xFFFFFFFF - 0.5)) * 10) / 1000
        
        while (rate*100) <= 0 {
            rate += 0.01
        }
        
        self.user["rate"] = JSON(rate * 100)
        
        // Multiply the loan by the rate, and then round it
        self.user["loans"]["friendly"] = JSON(round(self.user["loans"]["friendly"].double! * (1 + (rate/2)) * 100) / 100)
        self.user["loans"]["standard"] = JSON(round(self.user["loans"]["standard"].double! * (1 + rate) * 100) / 100)
        self.user["loans"]["super"] = JSON(round(self.user["loans"]["super"].double! * (1 + (rate*2)) * 100) / 100)
        
        // Compound bank balance if we don't owe anything!
        if self.owed() <= 0 {
            self.user["bankBalance"] = JSON(round(self.user["bankBalance"].double! * (1 + rate) * 100) / 100)
        }
        
        // Random events
        let event = self.events[Int(arc4random_uniform(UInt32(self.events.count)))]
        headline.stringValue = event["title"].stringValue
        subtitle.stringValue = event["sub"].stringValue
        
        // Build item fluctuation arrays
        var up: [String] = []
        var down: [String] = []
        if let upArray = event["up"].array {
            for item in upArray {
                up.append(item.string!)
            }
        }
        if let downArray = event["down"].array {
            for item in downArray {
                down.append(item.string!)
            }
        }
        
        // Regenerate and randomise items + prices:
        for location in ["treetopgully", "steamershill", "newnewtown", "utopolis", "lavamountain", "something", "bobsknuckle", "hell", "brokencreek"] {
            let inventory = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("stores", ofType: "json")!, options: .DataReadingMappedIfSafe, error: nil)!)[location]["inventory"].array!
            
            for itemNum in 0...inventory.count - 1 {
                
                // Don't do any of this if the item is a special item
                let name = self.stores[location]["inventory"][itemNum]["name"].string!
                if contains(kingItems, name) {
                    continue
                }
                
                // QUANTITY
                // Add 10% of original quantity
                var added = round(inventory[itemNum]["quantity"].double! * 0.1)
                if added == 0 { added = 1 }
                
                // 1 in 2 chance of adding anything
                added *= Double(arc4random_uniform(1))
                let newQuantity = self.stores[location]["inventory"][itemNum]["quantity"].double! + added
                
                // Finally, randomise the item as well
                self.stores[location]["inventory"][itemNum]["quantity"] = JSON(newQuantity * (1 + (Double(arc4random()) / 0xFFFFFFFF - 0.5)))
                
                // PRICE
                // We just randomise this slightly
                let oldPrice = self.stores[location]["inventory"][itemNum]["price"].double!
                var newPrice: Double = 0
                
                // New price should never be 0
                while round(newPrice*10)/10 <= 0 {
                    newPrice = (1 + (0.1 * (Double(arc4random()) / 0xFFFFFFFF) - 0.05))
                    if oldPrice > 0.1 {
                        newPrice *= oldPrice
                    }
                    
                    if contains(up, name) {
                        newPrice *= 1.2
                    } else if contains(down, name) {
                        newPrice *= 0.8
                    }
                }
                self.stores[location]["inventory"][itemNum]["price"] = JSON(round(newPrice*10)/10)
            }
        }
        
        // Randomise the prices of our own items
        for itemNum in 0...self.user["inventory"].count - 1 {
            let oldPrice = self.user["inventory"][itemNum]["price"].double!
            var newPrice: Double = 0
            
            // New price should always be > 0
            while round(newPrice*10)/10 <= 0 {
                newPrice = (1 + (0.1 * (Double(arc4random()) / 0xFFFFFFFF) - 0.05))
                if oldPrice > 0.1 {
                    newPrice *= oldPrice
                }
                println(newPrice)
                println(round(newPrice*10))
            }
            self.user["inventory"][itemNum]["price"] = JSON(round(newPrice*10)/10)
        }
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
        cashOnHand.stringValue = "$" + String(stringInterpolationSegment: user["balance"].double!) + " with me"
        cashInBank.stringValue = "$" + String(stringInterpolationSegment: user["bankBalance"].double!) + " in bank"
        cashInLoans.stringValue = "$" + String(stringInterpolationSegment: self.owed()) + " owed"
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
            } else if contains(kingItems, itemData["name"].string!) && self.owed() > 100 {
                
                // Don't let the user buy special items if they owe more than 100
                // so that they can't get the Gay Agenda on borrowed cash
                // Remove the buy/quantity stuff to prevent this
                for subview in cellView.subviews {
                    subview.removeFromSuperview!()
                }
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