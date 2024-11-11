import Foundation

public class Event {
    public let name: String
    internal var instances: [UUID:EventInstance]
    
    public init(name: String) {
        self.name = name
        instances = [:]
    }
    
    public func newInstance() -> EventInstance {
        let id = UUID()
        instances[id] = EventInstance(name: name, id: id)
        return instances[id]!
    }
}
