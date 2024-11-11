import Foundation

public enum Result: Codable {
    case success, failure, ungracefulEnd
}

private let DISSALLOWED_NAMES: Set<String> = ["start", "end"]

public class Owl {
    
    private static var events: [String:Event] = [:]
    
    public static func newEvent(name: String) -> EventInstance {
        if !events.contains(where: { $0.key == name }) {
            events[name] = Event(name: name)
        }
        return events[name]!.newInstance()
    }
    
    private static func sanityCheckEvent(_ eventName: String, _ id: UUID) -> Bool {
        if(!events.contains(where: {$0.key == eventName})) {
            return false
        }
        if (!events[eventName]!.instances.contains(where: {$0.key == id})) {
            return false
        }
        return true
    }
    
    /**
        Starts the given event. Note that:
     - The event should have already been created
     - This operation is  comprised of two main parts:
            - Updating the Event instance itself
            - Updating the queue of updates maintained by the Owl class
     */
    internal static func start(eventName: String, id: UUID) -> Bool {
        if(!sanityCheckEvent(eventName, id)) {
            return false
        }
        let event = Owl.events[eventName]!.instances[id]!
        if !event.steps.isEmpty {
            print("event already ongoing")
            return false
        }
        
        event.steps.append(Step("start"))
        
        // Update the queue of updates here
        
        return true
    }
    
    internal static func step(eventName: String, id: UUID, stepName: String) -> Bool {
        if(!sanityCheckEvent(eventName, id)) {
            return false
        }
        if DISSALLOWED_NAMES.contains(stepName) {
            print("The name \(eventName) is dissallowed as a step name. Aborting.")
            return false
        }
        var steps = Owl.events[eventName]!.instances[id]!.steps
        guard let last = steps.last else {
            print("Attempting to add a step without starting the event. Aborting.")
            return false
        }
        
        if last.name == "end" {
            print("Attempting to add a step after the event has ended. Aborting.")
            return false
        }
        
        steps.append(Step(stepName))
        
        // Update the queue of updates here
        
        return true
    }
    
    internal static func label(eventName: String, id: UUID, key: String,  val: Codable) -> Bool {
        if(!sanityCheckEvent(eventName, id)) {
            return false
        }
        var steps = Owl.events[eventName]!.instances[id]!.steps
        guard let last = steps.last else {
            print("Attempting to add a label without starting the event. Aborting.")
            return false
        }
        last.label(key: key, val: val)
        
        // Update the queue of updates here
        
        return true
    }
    
    internal static func end(eventName: String, id: UUID, result: Result) -> Bool {
        if(!sanityCheckEvent(eventName, id)) {
            return false
        }
        var event = Owl.events[eventName]!.instances[id]!
        
        guard let last = event.steps.last else {
            print("Attempting to close an event without starting it. Aborting.")
            return false
        }
        
        if last.name == "end" {
            print("Event already ended. Aborting.")
            return false
        }
        
        event.steps.append(Step("end"))
        if(!event.label(key: "result", val: result)) {
            return false
        }
        
        // Send data over the network here
        
        return true
    }
}
