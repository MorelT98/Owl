import XCTest
@testable import Owl

final class OwlTests: XCTestCase {
    
    func testStart() {
        let owl = Owl(event: "TEST_EVENT")
        
        XCTAssertTrue(owl.start())
        
        XCTAssertFalse(owl.start())
    }
    
    func testStep() {
        let owl = Owl(event: "TEST_EVENT")
        owl.start()
        
        XCTAssertTrue(owl.step("TEST_STEP"))
    }
    
    func testLabel() {
        let owl = Owl(event: "TEST_EVENT")
        XCTAssertFalse(owl.label(key: "key1", val: "val1"))
        
        owl.start()
        XCTAssertTrue(owl.label(key: "key1", val: "val1"))
    }
    
    func testClose() {
        let owl = Owl(event: "TEST_CLOSE")
        XCTAssertFalse(owl.close(result: .success))
        
        owl.start()
        XCTAssertTrue(owl.close(result: .success))
    }
}
