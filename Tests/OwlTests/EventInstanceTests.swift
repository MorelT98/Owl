import XCTest
@testable import Owl

final class EventInstanceTests: XCTestCase {
    let eventName = "TEST_NAME";
    var eventCount = 0;
    var updateCount = 0;
    
    override func setUp() {
        Owl.disableDataSend()
        eventCount = Owl.shared.events[eventName]?.instances.count ?? 0
        updateCount = Owl.shared.updates.count
    }
    
    func testNewEvent() {
        let event = Owl.newEvent(name: eventName)
        XCTAssertNotNil(Owl.shared.events.index(forKey: event.name))
        XCTAssertEqual(Owl.shared.events[eventName]!.instances.count, eventCount + 1)
    }
    
    func testStart() {
        let event = Owl.newEvent(name: eventName)
        
        XCTAssertTrue(event.start())
        XCTAssertEqual(event.steps.count, 1)
        XCTAssertTrue(event.steps.contains(where: {$0.name == "start"}))
        XCTAssertEqual(Owl.shared.updates.count, updateCount + 1)
        let update = Owl.shared.updates.last!
        XCTAssertTrue(update is StartUpdate)
        XCTAssertTrue(update.eventId == event.id)
        XCTAssertTrue(update.eventName == event.name)
        
        
        XCTAssertFalse(event.start())
        XCTAssertEqual(event.steps.count, 1)
        XCTAssertEqual(Owl.shared.updates.count, updateCount + 1)
    }
    
    func testStep() {
        let event = Owl.newEvent(name: eventName)
    
        XCTAssertFalse(event.step("TEST_STEP"))
        
        event.start()
        XCTAssertTrue(event.step("TEST_STEP"))
        XCTAssertEqual(event.steps.count, 2)
        XCTAssertEqual(event.steps.last?.name, "TEST_STEP")
        XCTAssertEqual(Owl.shared.updates.count, updateCount + 2)
        
        XCTAssertTrue(Owl.shared.updates.last is StepUpdate)
        let update = Owl.shared.updates.last as! StepUpdate
        XCTAssertEqual(update.eventId, event.id)
        XCTAssertEqual(update.eventName, event.name)
        XCTAssertEqual(update.stepName, "TEST_STEP")
        
        
        XCTAssertFalse(event.step("start"))
        XCTAssertFalse(event.step("end"))
    }
    
    func testLabel() {
        let event = Owl.newEvent(name: eventName)
        XCTAssertFalse(event.label(key: "key1", val: "val1"))
        
        event.start()
        XCTAssertTrue(event.label(key: "key1", val: "val1"))
        XCTAssertNotNil(event.steps.last?.labels.index(forKey: "key1"))
        
        XCTAssertTrue(Owl.shared.updates.last is LabelUpdate)
        let update = Owl.shared.updates.last as! LabelUpdate
        XCTAssertEqual(update.eventName, event.name)
        XCTAssertEqual(update.eventId, event.id)
        XCTAssertEqual(update.stepName, "start")
        XCTAssertEqual(update.key, "key1")
    }
    
    func testEnd() {
        let event = Owl.newEvent(name: "TEST_NAME")
        XCTAssertFalse(event.end(result: .success))
        
        event.start()
        XCTAssertTrue(event.end(result: .success))
        XCTAssertEqual(event.steps.count, 2)
        XCTAssertEqual(event.steps.last?.name, "end")
        XCTAssertNotNil(event.steps.last?.labels.index(forKey: "result"))
        
        XCTAssertTrue(Owl.shared.updates.last is EndUpdate)
        let update = Owl.shared.updates.last as! EndUpdate
        XCTAssertEqual(update.eventName, event.name)
        XCTAssertEqual(update.eventId, event.id)
        XCTAssertEqual(update.result, .success)
        
        XCTAssertFalse(event.end(result: .success))
    }
}
