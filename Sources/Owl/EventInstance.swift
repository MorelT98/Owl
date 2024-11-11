import Foundation

public class EventInstance {
    public let id: UUID
    public let name: String
    internal var steps: [Step]
    
    public init(name: String, id: UUID) {
        self.name = name
        self.id = id
        steps = []
    }
    
    public func start() -> Bool {
        return Owl.start(eventName: name, id: id)
    }
    
    public func step(_ name: String) -> Bool {
        return Owl.step(eventName: self.name, id: id, stepName: name)
    }
    
    public func label(key: String, val: Codable) -> Bool {
        return Owl.label(eventName: name, id: id, key: key, val: val)
    }
    
    
    public func end(result: Result) -> Bool {
        return Owl.end(eventName: name, id: id, result: result)
    }
    
    deinit {
        Owl.end(eventName: name, id: id, result: .ungracefulEnd)
    }
}
