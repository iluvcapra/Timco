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
        XCTAssertFalse(r.dropFrame)
    }
    
    func testTimecodeRepDrop() {
        let frameCount = 1830 // 30 * 61
        let r = TimecodeRep.with(frameCount: frameCount, fcm: .Count30Drop)
        XCTAssertEqual(r.hours, 0)
        XCTAssertEqual(r.minutes, 1)
        XCTAssertEqual(r.seconds, 1)
        XCTAssertEqual(r.frames, 2)
        XCTAssertTrue(r.dropFrame)
    }

    static var allTests = [
        ("testDropType", testDropType),
        ("testTimecodeRepNonDrop", testTimecodeRepNonDrop)
    ]
}
