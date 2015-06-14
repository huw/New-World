//
//  TitleScreenController.swift
//  New World
//
//  Created by Huw on 2015-05-12.
//  Copyright (c) 2015 Huw. All rights reserved.
//

import Cocoa
import AVKit

class TitleScreenController: MoviewController {

    @IBOutlet weak var player: AVPlayerView!
    var parentVC: AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        readFiles()
        
        self.playVideo(player, fileName: "titlescreen")
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        let next = segue.destinationController as! MoviewController
        next.stores = self.stores
        next.user = self.user
        next.events = self.events
        player.player.pause()
    }
    
    func readFiles() {
        self.stores = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("stores_save", ofType: "json")!, options: .DataReadingMappedIfSafe, error: nil)!)
        self.user = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("user_save", ofType: "json")!, options: .DataReadingMappedIfSafe, error: nil)!)
        self.events = JSON(data: NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("events", ofType: "json")!, options: .DataReadingMappedIfSafe, error: nil)!)
    }
    
    @IBAction func quitButton(sender: AnyObject) {
        println("QUIT")
        exit(0)
    }
    
    @IBAction func resetButton(sender: AnyObject) {
        // Two very long lines which copy the default dataset to the save files, overwriting them
        NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("user", ofType: "json")!, options: .DataReadingMappedIfSafe, error: nil)!.writeToFile(NSBundle.mainBundle().pathForResource("user_save", ofType: "json")!, atomically: false)
        NSData(contentsOfFile: NSBundle.mainBundle().pathForResource("stores", ofType: "json")!, options: .DataReadingMappedIfSafe, error: nil)!.writeToFile(NSBundle.mainBundle().pathForResource("stores_save", ofType: "json")!, atomically: false)
        readFiles()
    }
}
