import XCTest
@testable import Owl

final class EventTests: XCTestCase {

    func testNewInstance() {
        let event = Event()
        XCTAssertNotNil(event.getNewInstance())
    }

}
