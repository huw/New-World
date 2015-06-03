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
    
    var storeInventory: JSON = []
    var locationName: String = "steamershill"
    
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
        
        self.storeInventory = self.stores[locationName]["inventory"]
        
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
        
        cashOnHand.stringValue = String(stringInterpolationSegment: user["balance"].double!) + " with me"
        cashInBank.stringValue = String(stringInterpolationSegment: user["bankbalance"].double!) + " in bank"
        let loanBalance = user["loans"]["friendly"].double! + user["loans"]["standard"].double! + user["loans"]["super"].double!
        cashInLoans.stringValue = String(stringInterpolationSegment: loanBalance) + " owed"
    }
    
    @IBAction func addItem(sender: AnyObject) {
        let row = tableView.rowForView(sender.superview!!)
    }
    
    @IBAction func removeItem(sender: AnyObject) {
        let row = tableView.rowForView(sender.superview!!)
    }
}

extension CityScreenController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        let identifier = tableView.identifier!
        if identifier == "Buy Table" {
            return self.storeInventory.count
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
            let itemData = self.storeInventory[row]
            
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
                var data = String(itemData["quantity"].int!) + " " + itemData["name"].string!
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