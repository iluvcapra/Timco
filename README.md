# Timco

`Timco` converts back and forth between frame counts and the classic SMPTE representation.

## Example

    import Timco
    
    let f : FrameCount = 1_000
    let tc = TimecodeRep.with(frameCount: f, mode: .Count30)
    print(tc) // "00:00:33:10"
    
    let f2 : FrameCount = 1_830
    let tcDrop = TimecodeRep.with(frameCount:f2, mode: .Count30Drop)
    print(tcDrop) // "00:01:01;02"
    
    let tcStringRep = TimecodeRep(description: "12:00:10:01")
    let tcStringFrameCount = tcStringRep.frameCount(mode: .Count24)
    print(tcStringFrameCount) // 1037041
    
    
