import XCTest
@testable import Owl

final class EventInstanceTests: XCTestCase {
    
    func testStart() {
        let event = EventInstance(id: UUID())
        
        XCTAssertTrue(event.start())
        
        XCTAssertFalse(event.start())
    }
    
    func testStep() {
        let event = EventInstance(id: UUID())
        event.start()
        
        XCTAssertTrue(event.step("TEST_STEP"))
        
        XCTAssertFalse(event.step("start"))
        XCTAssertFalse(event.step("end"))
    }
    
    func testLabel() {
        let event = EventInstance(id: UUID())
        XCTAssertFalse(event.label(key: "key1", val: "val1"))
        
        event.start()
        XCTAssertTrue(event.label(key: "key1", val: "val1"))
    }
    
    func testClose() {
        let event = EventInstance(id: UUID())
        XCTAssertFalse(event.close(result: .success))
        
        event.start()
        XCTAssertTrue(event.close(result: .success))
        
        XCTAssertFalse(event.close(result: .success))
    }
}
