typealias FrameCount = Int

enum TimecodeFrameCountMode {
    case Count24
    case Count25
    case Count30
    case Count30Drop
    
    var integralFPS : Int {
        switch self {
        case .Count24: return 24
        case .Count25: return 25
        case .Count30, .Count30Drop:
            return 30
        }
    }
    
    var dropFrame : Bool {
        switch self {
        case .Count30Drop:
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
    let dropFrame : Bool
    
    static func dropFrameCount(_ fcm: TimecodeFrameCountMode, _ absoluteFrameCount: FrameCount) -> FrameCount {
        precondition(fcm.integralFPS == 30)
        let framesPerMinute = 30 * 60
        
        let (mins, _) = absoluteFrameCount
            .quotientAndRemainder(dividingBy: framesPerMinute)
        
        let (tenMins, _) = mins.quotientAndRemainder(dividingBy: 10)
        
        return (mins * 2) - (tenMins * 2)
    }
    
    static func modulateFrameCount(_ correctedFrameCount: FrameCount,
                                   _ fcm: TimecodeFrameCountMode) -> (Int, Int, Int, Int) {
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
        let (hh, mm, ss, ff) : (Int,Int,Int,Int) = modulateFrameCount(correctedFrameCount, fcm)
        
        return TimecodeRep(hours: hh, minutes: mm, seconds: ss, frames: ff,
                           dropFrame: fcm.dropFrame)
    }
    
    
}
