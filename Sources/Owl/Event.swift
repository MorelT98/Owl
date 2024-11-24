import Foundation

/**
 * Tracks all the instances of an event.
 * This allows the developer to create multiple event (instances)
 *  with the same event name
 */
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
