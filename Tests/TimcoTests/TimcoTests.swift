import XCTest
@testable import Timco

final class TimcoTests: XCTestCase {

    func testDropType() {
        XCTAssertFalse(TimecodeFrameCountMode.Count24.dropFrame)
        XCTAssertTrue(TimecodeFrameCountMode.Count30Drop.dropFrame)
    }
    
    func testTimecodeRepNonDrop() {
        let frameCount = 40
        let r = TimecodeRep.with(frameCount: frameCount, fcm: .Count24)
        XCTAssertEqual(r.hours, 0)
        XCTAssertEqual(r.minutes, 0)
        XCTAssertEqual(r.seconds, 1)
        XCTAssertEqual(r.frames, 16)
    }
    
    func testTimecodeRepDrop() {
        let frameCount = 1830 // 30 * 61
        let r = TimecodeRep.with(frameCount: frameCount, fcm: .Count30Drop)
        XCTAssertEqual(r.hours, 0)
        XCTAssertEqual(r.minutes, 1)
        XCTAssertEqual(r.seconds, 1)
        XCTAssertEqual(r.frames, 2)
    }
    
    func testStringRep() {
        let r = TimecodeRep(hours: 4, minutes: 12, seconds: 53, frames: 19)
        XCTAssertEqual(r.description, "04:12:53:19")
    }
    
    func testStringRepToFrameCount() {
        let r1 = TimecodeRep(hours: 0, minutes: 13, seconds: 9, frames: 1)
        let frames1 = r1.frameCount(fcm: .Count24)
        XCTAssertEqual(frames1, 18_937)
        
        let r2 = TimecodeRep(hours: 0, minutes: 1, seconds: 0, frames: 2)
        let frames2 = r2.frameCount(fcm: .Count30Drop)
        XCTAssertEqual(frames2, 1800)
    }
    
    func testValidation() {
        let r1 = TimecodeRep(hours: 1, minutes: 0, seconds: 0, frames: 0)
        XCTAssertTrue(r1.valid(for: .Count30Drop))
    }

    static var allTests = [
        ("testDropType", testDropType),
        ("testTimecodeRepNonDrop", testTimecodeRepNonDrop),
        ("testTimecodeRepDrop", testTimecodeRepDrop),
        ("testStringRep",testStringRep),
        ("testStringRepToFrameCount",testStringRepToFrameCount),
        ("testValidation",testValidation)
    ]
}
