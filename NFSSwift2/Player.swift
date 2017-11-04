//
//  Player.swift
//  NFSSwift2
//
//  Created by 璨 杨 on 15/12/4.
//  Copyright © 2015年 Gibbs. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreAudio

@objc protocol NFSAudioPlayerViewDelegate {
    
}

@objc protocol NFSAudioPlayerUpdateViewDelegate {
    
}

class NFSAudioPlayer: AVAudioPlayer {
    
    var _playerdelegate:NFSAudioPlayerDelegate? = nil;
    
    override init() {
        super.init();
    }
    
    init(sound:Sound, playerdelegate:NFSAudioPlayerDelegate?) {
        super.init();
        _playerdelegate = playerdelegate;
    }
    
    override func play() -> Bool {
        return super.play();
    }
}
