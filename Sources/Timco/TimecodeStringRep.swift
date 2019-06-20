//
//  File.swift
//  
//
//  Created by Jamie Hardt on 6/19/19.
//

import Foundation

extension TimecodeRep : CustomStringConvertible {
    
    var description : String {
        let separator = self.dropFrame ? ";" : ":"
        return String(format: "%02i:%02i:%02i%@%02i",
                          self.hours, self.minutes,
                          self.seconds, separator,  self.frames)
    }
    
}
