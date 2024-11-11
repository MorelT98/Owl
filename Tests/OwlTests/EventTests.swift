import XCTest
@testable import Owl

final class EventTests: XCTestCase {

    func testNewInstance() {
        let event = Event(name: "TEST_EVENT")
        XCTAssertNotNil(event.newInstance())
    }

}
