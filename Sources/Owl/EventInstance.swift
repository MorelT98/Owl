import Foundation

/**
 * Represents an instance of an event with the given event name
 * An event instance object can be passed around to track multiple
 * steps of a lifecycle.
 */
public class EventInstance {
    public let id: UUID
    public let name: String
    public let creationTime: Int64
    internal var steps: [Step]
    
    public init(name: String, id: UUID) {
        self.name = name
        self.id = id
        self.creationTime = Int64(Date().timeIntervalSince1970)
        steps = []
    }
    
    public func start() -> Bool {
        return Owl.shared.start(eventName: name, id: id, creationTime: creationTime)
    }
    
    public func step(_ name: String) -> Bool {
        return Owl.shared.step(eventName: self.name, id: id, stepName: name)
    }
    
    public func label(key: String, val: Codable) -> Bool {
        return Owl.shared.label(eventName: name, id: id, key: key, val: val)
    }
    
    
    public func end(result: Result) -> Bool {
        return Owl.shared.end(eventName: name, id: id, result: result)
    }
    
    deinit {
        Owl.shared.end(eventName: name, id: id, result: .ungracefulEnd)
    }
}
