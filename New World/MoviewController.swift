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
}

