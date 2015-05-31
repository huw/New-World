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
    @IBOutlet weak var player: AVPlayerView!
    @IBOutlet weak var storeName: NSTextField!
    @IBOutlet weak var storeLocation: NSTextField!
    @IBOutlet weak var location: NSTextField!
    
    var storeInventory: JSON = []
    var locationName: String = "steamershill"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Play the video for this location
        self.playVideo(player, fileName: locationName)
        
        self.storeInventory = self.stores[locationName]["inventory"]
        
        // Set the table view's delegate and data source
        tableView.setDataSource(self)
        tableView.setDelegate(self)
        tableView.reloadData()
        
        // Set the values of labels
        storeName.stringValue = stores[locationName]["storeName"].stringValue
        storeLocation.stringValue = stores[locationName]["storeLocation"].stringValue
        location.stringValue = stores[locationName]["name"].stringValue
    }
    
    // Pause the video to save CPU when we leave the view
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        player.player.pause()
        
        if segue.destinationController is TrainStationController {
            let destination = segue.destinationController as! TrainStationController
            
            destination.locationName = self.locationName
        } else if segue.destinationController is BankController {
            let destination = segue.destinationController as! BankController
            
            destination.locationName = self.locationName
            
        }
    }
}

extension CityScreenController: NSTableViewDataSource {
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return self.storeInventory.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let identifier = tableColumn!.identifier
        var cellView: NSTableCellView = tableView.makeViewWithIdentifier(identifier, owner: self) as! NSTableCellView
        let itemData = self.storeInventory[row]
        
        // Set the data for each column to the correct strings from the store data
        if identifier == "ItemName" {
            cellView.textField!.stringValue = itemData["name"].string!
        } else if identifier == "ItemQuantity" {
            cellView.textField!.stringValue = String(itemData["quantity"].int!)
        } else if identifier == "ItemPrice" {
            cellView.textField!.stringValue = "$" + String(stringInterpolationSegment: itemData["price"].double!)
        }
        
        return cellView
    }
}

extension CityScreenController: NSTableViewDelegate {
}