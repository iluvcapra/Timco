typealias FrameCount = Int

enum TimecodeFrameCountMode {
    case Count24
    case Count25
    case Count30
    case Count30Drop
    case Count48
    case Count60
    case Count60Drop
    
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
    
    var dropFrame : Bool {
        switch self {
        case .Count30Drop, .Count60Drop:
            return true
        default:
            return false
        }
    }
}

struct TimecodeRep  {
    
    let hours : Int
    let minutes : Int
    let seconds : Int
    let frames : Int
    
    static func dropFrameCount(_ fcm: TimecodeFrameCountMode, _ absoluteFrameCount: FrameCount) -> FrameCount {
        precondition(fcm.integralFPS == 30 || fcm.integralFPS == 60)
        let framesPerMinute = fcm.integralFPS * 60
        let dropFrames = fcm.integralFPS == 30 ? 2 : 4
        
        let (mins, _) = absoluteFrameCount
            .quotientAndRemainder(dividingBy: framesPerMinute)
        
        let (tenMins, _) = mins.quotientAndRemainder(dividingBy: 10)
        
        return (mins * dropFrames) - (tenMins * dropFrames)
    }
    
    static func modulateFrameCount(_ correctedFrameCount: FrameCount,
                                   _ fcm: TimecodeFrameCountMode) -> (hh:Int, mm:Int, ss:Int, ff:Int) {
        let secondsPerMinute = 60
        let minutesPerHour = 60
        let (secs, ff) = (correctedFrameCount as Int).quotientAndRemainder(dividingBy: fcm.integralFPS)
        let (mins, ss) = secs.quotientAndRemainder(dividingBy: secondsPerMinute)
        let (hours, mm) = mins.quotientAndRemainder(dividingBy: minutesPerHour)
        let hh = hours % 24
        
        return (hh, mm, ss, ff)
    }
    
    static func with(frameCount: FrameCount, fcm: TimecodeFrameCountMode) -> TimecodeRep {
        
        let absoluteFrameCount = abs(frameCount)
        let dropCorrection : Int = fcm.dropFrame ? dropFrameCount(fcm, absoluteFrameCount) : 0
        let correctedFrameCount : FrameCount = absoluteFrameCount + dropCorrection
        let (hh, mm, ss, ff) = modulateFrameCount(correctedFrameCount, fcm)
        
        return TimecodeRep(hours: hh, minutes: mm, seconds: ss, frames: ff)
    }
    
    static func frameCount(hh :Int, mm :Int, ss :Int, ff :Int,
                           fcm :TimecodeFrameCountMode) -> FrameCount {
        
        let absoluteFrameCount : FrameCount = {
            let seconds = [3600 * hh, 60 * mm, ss].reduce(0,+)
            return seconds * fcm.integralFPS + ff
        }()
    
        let dropCorrection : Int = fcm.dropFrame ? TimecodeRep.dropFrameCount(fcm, absoluteFrameCount) : 0
        let correctedFrameCount : FrameCount = absoluteFrameCount - dropCorrection
        return correctedFrameCount
    }
    
    func valid(for fcm : TimecodeFrameCountMode) -> Bool {
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
    
    func frameCount(fcm : TimecodeFrameCountMode) -> FrameCount {
        return TimecodeRep.frameCount(hh: self.hours, mm: self.minutes,
                                      ss: self.seconds, ff: self.frames,
                                      fcm: fcm)
    }
}
