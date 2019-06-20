//
//  File.swift
//  
//
//  Created by Jamie Hardt on 6/19/19.
//

import Foundation

extension TimecodeRep : CustomStringConvertible {
    
    var description : String {
        return String(format: "%02i:%02i:%02i:%02i",
                          self.hours, self.minutes,
                          self.seconds,  self.frames)
    }
    
}
