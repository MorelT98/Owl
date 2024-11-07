import Foundation

public class Owl {
    
    private static var events: [String:Event] = [:]
    
    public static func getNewEvent(name: String) -> EventInstance {
        if !events.contains(where: { $0.key == name }) {
            events[name] = Event()
        }
        return events[name]!.getNewInstance()
    }
    
    
}
