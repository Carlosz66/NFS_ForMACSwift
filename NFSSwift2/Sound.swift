//
//  Wave.swift
//  NFSSwift2
//
//  Created by 璨 杨 on 15/12/4.
//  Copyright © 2015年 Gibbs. All rights reserved.
//

import Cocoa
import AVFoundation

extension NSTimeInterval {
    func ToString() -> String {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "HH:mm:ss";
        formatter.timeZone = NSTimeZone(name: "UTC");
        let duration = NSDate(timeIntervalSince1970: self);
        let durationstring = formatter.stringFromDate(duration);
        return durationstring;
    }
}

enum SoundInfoEnum {
    case SoundDisplayName;
    case SoundRelPath;
    case SoundScore;
    case SoundDes;
}

class Sound: NSObject {
    
}

class SingleFileSound: Sound {
    var Channels = Array<Channel>();
    
}

class MultipleFileSound: Sound {
    
}
