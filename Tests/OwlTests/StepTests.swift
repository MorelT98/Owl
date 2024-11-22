import XCTest
@testable import Owl

final class StepTests: XCTestCase {

    func testStepInit() {
        let step = Step(name: "test_step", number: 0)
        XCTAssertEqual(step.name, "test_step")
        XCTAssertEqual(step.number, 0)
        XCTAssertEqual(step.labels.count, 1)
        XCTAssertNotNil(step.labels["time_ms"])
    }

}
