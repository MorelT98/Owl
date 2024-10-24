import XCTest
@testable import Owl

final class StepTests: XCTestCase {

    func testStepInit() {
        let step = Step("test_step")
        XCTAssertEqual(step.name, "test_step")
        XCTAssertEqual(step.labels.count, 1)
        XCTAssertNotNil(step.labels["time_ms"])
    }

}
