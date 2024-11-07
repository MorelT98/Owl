import Foundation

public class Event {
    private var instances: [UUID:EventInstance]
    
    public init() {
        instances = [:]
    }
    
    public func getNewInstance() -> EventInstance {
        let id = UUID()
        instances[id] = EventInstance(id: id)
        return instances[id]!
    }
}
