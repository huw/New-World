//
//  ViewController.swift
//  New World
//
//  Created by Huw on 2015-05-06.
//  Copyright (c) 2015 Huw. All rights reserved.
//

import Cocoa
import AVFoundation
import AVKit

class MoviewController: NSViewController {
    
    var bgMovie: AVPlayerView = AVPlayerView()
    var fileName: String = "utopolis"
    
    // Load the JSON file containing the data on locations and stores
    var stores: JSON = []
    var user: JSON = []
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        // Unregister the observer (good memory management!)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: bgMovie.player.currentItem)
    }
    
    func playVideo(bgMovie: AVPlayerView, fileName: String) {
        self.bgMovie = bgMovie
        self.fileName = fileName
        
        // Get the path of the video that will be the background of this screen
        var path = NSBundle.mainBundle().pathForResource(self.fileName, ofType: "mp4")
        
        // Make a player object, and put it into the frame we have
        self.bgMovie.player = AVPlayer(URL: NSURL(fileURLWithPath: path!))
        
        var player = self.bgMovie.player
        
        player.muted = true
        
        // Don't do anything when the video ends
        player.actionAtItemEnd = .None
        
        // Handle the 'video ended' notification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "restartVideo:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player.currentItem)
        
        player.play()
    }

    // Small function to handle the 'restart video' notification
    func restartVideo(sender: AnyObject) {
        self.bgMovie.player.seekToTime(CMTimeMake(0, 1))
        self.bgMovie.player.play()
    }
    
    // I'm so sorry I had to use this. I really didn't want to, but time constraints -_-
    func errorBox(message: String, explanation: String = "") {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = explanation
        alert.addButtonWithTitle("OK")
        alert.runModal()
    }
    
    // A convenience for the amount of cash we owe
    func owed() -> Double {
        return self.user["loans"]["friendly"].double! + self.user["loans"]["standard"].double! + self.user["loans"]["super"].double!
    }
}

