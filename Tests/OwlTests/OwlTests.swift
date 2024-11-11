import XCTest
@testable import Owl

final class OwlTests: XCTestCase {

    func testNewEvent() {
        let event = Owl.newEvent(name: "TEST_EVENT")
        XCTAssertNotNil(event)
    }

}
