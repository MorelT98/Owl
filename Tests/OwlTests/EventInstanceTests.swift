import XCTest
@testable import Owl

final class EventInstanceTests: XCTestCase {
    
    func testStart() {
        let event = Owl.newEvent(name: "TEST_NAME")
        
        XCTAssertTrue(event.start())
        
        XCTAssertFalse(event.start())
    }
    
    func testStep() {
        let event = Owl.newEvent(name: "TEST_NAME")
        event.start()
        
        XCTAssertTrue(event.step("TEST_STEP"))
        
        XCTAssertFalse(event.step("start"))
        XCTAssertFalse(event.step("end"))
    }
    
    func testLabel() {
        let event = Owl.newEvent(name: "TEST_NAME")
        XCTAssertFalse(event.label(key: "key1", val: "val1"))
        
        event.start()
        XCTAssertTrue(event.label(key: "key1", val: "val1"))
    }
    
    func testEnd() {
        let event = Owl.newEvent(name: "TEST_NAME")
        XCTAssertFalse(event.end(result: .success))
        
        event.start()
        XCTAssertTrue(event.end(result: .success))
        
        XCTAssertFalse(event.end(result: .success))
    }
}
