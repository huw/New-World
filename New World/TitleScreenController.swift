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
        
        self.playVideo(player, fileName: "hell")
    }
    
    override func prepareForSegue(segue: NSStoryboardSegue, sender: AnyObject?) {
        player.player.pause()
    }
    
    @IBAction func quitButton(sender: AnyObject) {
        println("QUIT")
        exit(0)
    }
}
