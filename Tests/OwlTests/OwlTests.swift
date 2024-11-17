import XCTest
@testable import Owl

final class OwlTests: XCTestCase {

    func testNewEvent() {
        let event = Owl.newEvent(name: "TEST_EVENT")
        XCTAssertNotNil(event)
    }
    
    func testUpdatesOnOneEvent() {
        Owl.setPublishTimeInterval(to: 1.0)
        let event = Owl.newEvent(name: "TEST_EVENT")
        event.start()
        event.step("TEST_STEP1")
        event.label(key: "k1", val: "v1")
        event.step("TEST_STEP2")
        event.label(key: "k2", val: "v2")
        event.label(key: "k3", val: "v3")
        event.end(result: .success)
        event.end(result: .failure)
        XCTAssertEqual(Owl.updates.count, 7)
        Thread.sleep(forTimeInterval: 2.0)
        XCTAssertTrue(Owl.updates.isEmpty)
    }

}
