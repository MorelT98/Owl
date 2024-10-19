import Foundation

public enum Result {
    case success, failure, ungracefulEnd
}

public class Owl {
    
    private let event: String
    private var steps: [Step]
    
    public init(event: String) {
        self.event = event
        steps = []
    }
    
    public func start() -> Bool {
        if !steps.isEmpty {
            print("event already ongoing")
            return false
        }
        
        steps.append(Step("start"))
        return true
    }
    
    public func step(_ name: String) -> Bool {
        guard let last = steps.last else {
            print("Attempting to add a step without starting the event. Aborting.")
            return false
        }
        
        if last.name == "end" {
            print("Attempting to add a step after the event has ended. Aborting.")
            return false
        }
        
        steps.append(Step(name))
        return true
    }
    
    public func label(key: String, val: Any) -> Bool {
        guard let last = steps.last else {
            print("Attempting to add a label without starting the event. Aborting.")
            return false
        }
        last.label(key: key, val: val)
        return true
    }
    
    
    public func close(result: Result) -> Bool {
        guard let last = steps.last else {
            print("Attempting to close an event without starting it. Aborting.")
            return false
        }
        
        if last.name == "end" {
            print("Event already ended. Aborting.")
            return false
        }
        
        steps.append(Step("end"))
        label(key: "result", val: result)
        
        // Send data over the network here
        
        return true
    }
    
    deinit {
        close(result: .ungracefulEnd)
    }
}
