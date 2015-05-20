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

    @IBOutlet weak var player: AVPlayerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.playVideo(player, fileName: "trainstation")
    }
}
