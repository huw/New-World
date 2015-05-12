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

    @IBOutlet weak var playButton: NSButton!
    @IBOutlet weak var quitButton: NSButton!
    @IBOutlet weak var player: AVPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bgMovie = player
        self.fileName = "titlescreen"
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        exit(0)
    }
}
