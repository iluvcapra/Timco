import XCTest
@testable import Timco

final class TimcoTests: XCTestCase {

    func testDropType() {
        XCTAssertFalse(TimecodeFrameCountMode.Count24.dropFrame)
        XCTAssertTrue(TimecodeFrameCountMode.Count30Drop.dropFrame)
    }
    
    func testTimecodeRepNonDrop() {
        let frameCount = 40
        let r = TimecodeRep.with(frameCount: frameCount, mode: .Count24)
        XCTAssertEqual(r.hours, 0)
        XCTAssertEqual(r.minutes, 0)
        XCTAssertEqual(r.seconds, 1)
        XCTAssertEqual(r.frames, 16)
    }
    
    func testTimecodeRepDrop() {
        let frameCount = 1830 // 30 * 61
        let r = TimecodeRep.with(frameCount: frameCount, mode: .Count30Drop)
        XCTAssertEqual(r.hours, 0)
        XCTAssertEqual(r.minutes, 1)
        XCTAssertEqual(r.seconds, 1)
        XCTAssertEqual(r.frames, 2)
    }
    
    func testStringRep() {
        let r = TimecodeRep(hours: 4, minutes: 12, seconds: 53, frames: 19, dropMark: false)
        XCTAssertEqual(r.description, "04:12:53:19")
    }
    
    func testStringRepToFrameCount() {
        let r1 = TimecodeRep(hours: 0, minutes: 13, seconds: 9, frames: 1, dropMark: false)
        let frames1 = r1.frameCount(mode: .Count24)
        XCTAssertEqual(frames1, 18_937)
        
        let r2 = TimecodeRep(hours: 0, minutes: 1, seconds: 0, frames: 2, dropMark: true)
        let frames2 = r2.frameCount(mode: .Count30Drop)
        XCTAssertEqual(frames2, 1800)
    }
    
    func testValidation() {
        let r1 = TimecodeRep(hours: 1, minutes: 0, seconds: 0, frames: 0, dropMark: true)
        XCTAssertTrue(r1.valid(for: .Count30Drop))
    }
    
    func testFromString() {
        guard let r1 = TimecodeRep("01:14:19:03") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(r1.hours == 1)
        XCTAssertTrue(r1.minutes == 14)
        XCTAssertTrue(r1.seconds == 19)
        XCTAssertTrue(r1.frames == 3)
    }

    static var allTests = [
        ("testDropType", testDropType),
        ("testTimecodeRepNonDrop", testTimecodeRepNonDrop),
        ("testTimecodeRepDrop", testTimecodeRepDrop),
        ("testStringRep",testStringRep),
        ("testStringRepToFrameCount",testStringRepToFrameCount),
        ("testValidation",testValidation),
        ("testFromString",testFromString)
    ]
}
