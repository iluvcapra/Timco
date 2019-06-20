//
//  File.swift
//  
//
//  Created by Jamie Hardt on 6/20/19.
//

import Foundation

/// The frame count mode.
///
/// A mode defines how many frames are counted in a timecode second, and
/// wether or not to drop frames from the count.
enum TimecodeFrameCountMode {
    /// 24 frames per second counting mode
    case Count24
    /// 25 frames per second counting mode
    case Count25
    /// 30 frames per second counting mode
    case Count30
    /// 30 frames per second counting mode, dropping frame numbers according to the
    /// standard method predetermined in order average 29.97 frames
    /// per second over one hour.
    case Count30Drop
    /// 48 frames per second counting mode
    case Count48
    /// 60 frames per second counting mode
    case Count60
    /// 60 frames per second counting mode, dropping frame numbers according to the
    /// standard method predetermined in order average 59.94 frames
    /// per second over one hour.
    case Count60Drop
    
    /// The number of frames that must be advanced before the second
    /// field of timecode field advances.
    var integralFPS : Int {
        switch self {
        case .Count24: return 24
        case .Count25: return 25
        case .Count30, .Count30Drop:
            return 30
        case .Count48: return 48
        case .Count60: return 60
        case .Count60Drop:
            return 60
        }
    }
    
    /// Drop frame logic in effect.
    var dropFrame : Bool {
        switch self {
        case .Count30Drop, .Count60Drop:
            return true
        default:
            return false
        }
    }
}
