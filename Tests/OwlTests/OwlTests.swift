import XCTest
@testable import Owl

final class OwlTests: XCTestCase {
    
    override func setUp() {
        Owl.clearUpdates()
        Owl.disableDataSend()
    }

    func testNewEvent() {
        let event = Owl.newEvent(name: "TEST_EVENT")
        XCTAssertNotNil(event)
    }
    
    func testUpdatesOnOneEvent() {
        let event = Owl.newEvent(name: "TEST_EVENT")
        event.start()
        event.step("TEST_STEP1")
        event.label(key: "k1", val: "v1")
        event.step("TEST_STEP2")
        event.label(key: "k2", val: "v2")
        event.label(key: "k3", val: "v3")
        event.end(result: .success)
        event.end(result: .failure)
        XCTAssertEqual(Owl.shared.updates.count, 7)
        Thread.sleep(forTimeInterval: 2.0)
        XCTAssertTrue(Owl.shared.updates.isEmpty)
    }

}
