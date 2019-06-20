//
//  File.swift
//  
//
//  Created by Jamie Hardt on 6/19/19.
//

import Foundation

extension TimecodeRep : LosslessStringConvertible {
    var description : String {
        return String(format: "%02i:%02i:%02i:%02i",
                          self.hours, self.minutes,
                          self.seconds,  self.frames)
    }

    init?(_ description: String) {
        let scanner = Scanner(string: description)
        
        var hh : Int = 0
        var mm : Int = 0
        var ss : Int = 0
        var ff : Int = 0
        
        guard scanner.scanInt(&hh) else { return nil }
        guard scanner.scanString(":", into: nil) else { return nil }
        guard scanner.scanInt(&mm) else { return nil }
        guard scanner.scanString(":", into: nil) else { return nil }
        guard scanner.scanInt(&ss) else { return nil }
        guard scanner.scanString(":", into: nil) ||
            scanner.scanString(":", into: nil) else { return nil }
        guard scanner.scanInt(&ff) else { return nil }
        
        self.init(hours: hh, minutes: mm, seconds: ss, frames : ff)
    }
}
