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
    var fileName = "titlescreen"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the path of the video that will be the background of this screen
        var path = NSBundle.mainBundle().pathForResource(self.fileName, ofType: "mp4")
        
        // Make a player object, and put it into the frame we have
        bgMovie.player = AVPlayer(URL: NSURL(fileURLWithPath: path!))
        
        var player = bgMovie.player
        
        player.play()
        player.muted = true
        
        // Don't do anything when the video ends
        player.actionAtItemEnd = .None
        
        // Handle the 'video ended' notification
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "restartVideo:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: player.currentItem)
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        // Unregister the observer (good memory management!)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: bgMovie.player.currentItem)
    }

    // Small function to handle the 'restart video' notification
    func restartVideo(sender: AnyObject) {
        bgMovie.player.seekToTime(CMTimeMake(0, 1))
        bgMovie.player.play()
    }

}

