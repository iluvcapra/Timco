import Foundation


/// A duration, measured in frames.
typealias FrameCount = Int

/**
 A representation of a SMPTE timecode, of the format "00:00:00:00".
 
 This object performs no validation on timecodes created through the standard
 initializer, any four `Int`s can be used, these will not be checked for their range
 or their validity relative to the drop frame mark. Use the `valid(for:)` method
 to check this.
 */
struct TimecodeRep  {
    
    let hours : Int
    let minutes : Int
    let seconds : Int
    let frames : Int
    /**
     Indicates if the timecode should be displayed with a semicolon before the
     frames field, indicating dropped-frame counting.
     
     This field is only used when converting to and from text representations, all
     artihmetic and translation to frame counts occurs with regard to the
     `TimecodeFrameCountMode` passed. */
    let dropMark : Bool


    private static func dropFrameCount(_ fcm: TimecodeFrameCountMode, _ absoluteFrameCount: FrameCount) -> FrameCount {
        precondition(fcm.integralFPS == 30 || fcm.integralFPS == 60)
        let framesPerMinute = fcm.integralFPS * 60
        let dropFrames = fcm.integralFPS == 30 ? 2 : 4
        
        let (mins, _) = absoluteFrameCount
            .quotientAndRemainder(dividingBy: framesPerMinute)
        
        let (tenMins, _) = mins.quotientAndRemainder(dividingBy: 10)
        
        return (mins * dropFrames) - (tenMins * dropFrames)
    }
    
    private static func modulateFrameCount(_ correctedFrameCount: FrameCount,
                                   _ fcm: TimecodeFrameCountMode) -> (hh:Int, mm:Int, ss:Int, ff:Int) {
        let secondsPerMinute = 60
        let minutesPerHour = 60
        let (secs, ff) = (correctedFrameCount as Int).quotientAndRemainder(dividingBy: fcm.integralFPS)
        let (mins, ss) = secs.quotientAndRemainder(dividingBy: secondsPerMinute)
        let (hours, mm) = mins.quotientAndRemainder(dividingBy: minutesPerHour)
        let hh = hours % 24
        
        return (hh, mm, ss, ff)
    }
    
    private static func frameCount(hh :Int, mm :Int, ss :Int, ff :Int,
                                   fcm :TimecodeFrameCountMode) -> FrameCount {
        
        let absoluteFrameCount : FrameCount = {
            let seconds = [3600 * hh, 60 * mm, ss].reduce(0,+)
            return seconds * fcm.integralFPS + ff
        }()
        
        let dropCorrection : Int = fcm.dropFrame ? TimecodeRep.dropFrameCount(fcm, absoluteFrameCount) : 0
        let correctedFrameCount : FrameCount = absoluteFrameCount - dropCorrection
        return correctedFrameCount
    }
    
    /**
     Create with a new timecode representation with a frame count and counting mode.
     
     - parameter frameCount: the count of frames. Zero frames is "00:00:00:00"
     - parameter fcm: the frame count mode to use
     */
    static func with(frameCount: FrameCount, fcm: TimecodeFrameCountMode) -> TimecodeRep {
        
        let absoluteFrameCount = abs(frameCount)
        let dropCorrection : Int = fcm.dropFrame ? dropFrameCount(fcm, absoluteFrameCount) : 0
        let correctedFrameCount : FrameCount = absoluteFrameCount + dropCorrection
        let (hh, mm, ss, ff) = modulateFrameCount(correctedFrameCount, fcm)
        
        return TimecodeRep(hours: hh, minutes: mm, seconds: ss, frames: ff,
                           dropMark: fcm.dropFrame)
    }
    
    /**
     Evaluates the validity of the timecode representation for a given frame count mode.
     
     Each field is checked to confirm it is positive and within bounds, and the frames field is
     checked to make sure it refers to a valid frame if the given `fcm` is drop-frame.
     
     - parameter fcm : The frame count mode to validate this timecode against.
     - returns: `true` if the stored timecode is valid, `false` otherwise.
     */
    func valid(for fcm : TimecodeFrameCountMode) -> Bool {
        guard self.hours >= 0 && minutes >= 0 &&
            seconds >= 0 && frames >= 0 else {
            return false
        }
        guard self.hours < 24 && self.minutes < 60 &&
            self.seconds < 60 && self.frames < fcm.integralFPS else {
                return false
        }
        
        guard fcm.dropFrame else {
            return true
        }
        
        if minutes % 10 != 0 && seconds == 0 {
            if fcm.integralFPS == 30 && [0,1].contains(frames) {
                return false
            } else if fcm.integralFPS == 60 && [0,1,2,3].contains(frames) {
                return false
            }
        }

        return true
    }
    
    /**
     The frame count for this timecode, using the given frame count mode.
     
     - parameter fcm: The frame count mode to use.
     - returns: The frame count.
     */
    func frameCount(fcm : TimecodeFrameCountMode) -> FrameCount {
        return TimecodeRep.frameCount(hh: self.hours, mm: self.minutes,
                                      ss: self.seconds, ff: self.frames,
                                      fcm: fcm)
    }
}

extension TimecodeRep : LosslessStringConvertible {
    /// The string representation
    ///
    /// This will be in the standard form, "hh:mm:ss:ff". The final colon will
    /// be printed as a semicolon if the `dropMark` is `true`.
    var description : String {
        return String(format: "%02i:%02i:%02i:%02i",
                      self.hours, self.minutes,
                      self.seconds,  self.frames)
    }
    
    init?(_ description: String) {
        let scanner = Scanner(string: description)
        
        let ifs = CharacterSet(charactersIn: ":;")
        
        var hh : Int = 0
        var mm : Int = 0
        var ss : Int = 0
        var ff : Int = 0
        
        guard scanner.scanInt(&hh) else { return nil }
        guard scanner.scanCharacters(from: ifs, into: nil) else { return nil }
        guard scanner.scanInt(&mm) else { return nil }
        guard scanner.scanCharacters(from: ifs, into: nil) else { return nil }
        guard scanner.scanInt(&ss) else { return nil }
        if scanner.scanString(";", into: nil) {
            dropMark = true
        } else if scanner.scanString(":", into: nil) {
            dropMark = false
        } else {
            return nil
        }
        guard scanner.scanInt(&ff) else { return nil }
        
        hours = hh
        minutes = mm
        seconds = ss
        frames = ff
    }
}
