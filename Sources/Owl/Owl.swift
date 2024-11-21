import Foundation

public enum Result: String, CaseIterable {
    case success = "success"
    case failure = "failure"
    case ungracefulEnd = "ungracefulEnd"
}

private let DISSALLOWED_NAMES: Set<String> = ["start", "end"]

// Will publish at most <MAX_CAPACITY> updates to the server every <PUBLISH_INTERVAL> seconds
private let PUBLISH_INTERVAL: TimeInterval = 1
private let MAX_CAPACITY = 20

public class Owl {
    
    internal static var events: [String:Event] = [:]
    
    internal static var updates: [Update] = []
    
    internal static var executor: PeriodicExecutor = PeriodicExecutor()
    
    internal static var initialized = false
    
    internal static var publishInterval = PUBLISH_INTERVAL
        
    internal static func setPublishTimeInterval(to newPublishInterval: TimeInterval) {
        publishInterval = newPublishInterval
    }
    
    public static func newEvent(name: String) -> EventInstance {
        if !initialized {
            executor.scheduleTask(publishUpdates, interval: publishInterval)
            // Initialize WebSocket connection here
            initialized = true
        }
        if events.index(forKey: name) == nil {
            events[name] = Event(name: name)
        }
        return events[name]!.newInstance()
    }
    
    private static func sanityCheckEvent(_ eventName: String, _ id: UUID) -> Bool {
        if events.index(forKey: eventName) == nil {
            return false
        }
        if events[eventName]!.instances.index(forKey: id) == nil {
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
        if !sanityCheckEvent(eventName, id) {
            return false
        }
        let event = Owl.events[eventName]!.instances[id]!
        if !event.steps.isEmpty {
            print("event already ongoing")
            return false
        }
        
        event.steps.append(Step("start"))
        
        updates.append(StartUpdate(eventName: eventName, eventId: id))
        
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

        guard let last = Owl.events[eventName]!.instances[id]!.steps.last else {
            print("Attempting to add a step without starting the event. Aborting.")
            return false
        }
        
        if last.name == "end" {
            print("Attempting to add a step after the event has ended. Aborting.")
            return false
        }
        
        let step = Step(stepName)
        Owl.events[eventName]!.instances[id]!.steps.append(step)
        
        updates.append(StepUpdate(eventName: eventName, eventId: id, stepName: stepName, stepTime: step.time))
        
        return true
    }
    
    internal static func label(eventName: String, id: UUID, key: String,  val: Codable) -> Bool {
        if !sanityCheckEvent(eventName, id) {
            return false
        }
        
        if Owl.events[eventName]!.instances[id]!.steps.last == nil {
            print("Attempting to add a label without starting the event. Aborting.")
            return false
        }
        Owl.events[eventName]!.instances[id]!.steps.last?.label(key: key, val: val)
        
        let lastStepName = Owl.events[eventName]!.instances[id]!.steps.last!.name
        
        updates.append(LabelUpdate(eventName: eventName, eventId: id, stepName: lastStepName, key: key, val: val))
        
        return true
    }
    
    internal static func end(eventName: String, id: UUID, result: Result) -> Bool {
        if !sanityCheckEvent(eventName, id) {
            return false
        }
        
        let event = Owl.events[eventName]!.instances[id]!
        
        guard let lastStep = event.steps.last else {
            print("Attempting to close an event without starting it. Aborting.")
            return false
        }
        
        if lastStep.name == "end" {
            print("Event already ended. Aborting.")
            return false
        }
        
        let step = Step("end")
        step.label(key: "result", val: result.rawValue)
        event.steps.append(step)
        
        updates.append(EndUpdate(eventName: eventName, eventId: id, result: result))
        
        return true
    }
    
    private static func publishUpdates() {
        let updatesCount = min(MAX_CAPACITY, updates.count)
        if updatesCount == 0 {
            return
        }
        
        var data = "".data(using: .utf8)!
        for _ in 1...updatesCount {
            let update = updates.removeFirst()
            guard let updateJSON = JSONEncode(update) else {continue}
            data += updateJSON
        }
        sendData(data)
        print(String(data:data, encoding: .utf8)!)
    }
    
    private static func sendData(_ data: Data) {
        var request = URLRequest(url: URL(string: "example.com")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONEncoder().encode(data)
        } catch {
            print("Error encoding post data: \(error)")
            return
        }
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                print("Error sending request: \(error)")
                return
            }
            if let data = data {
//              let response = try JSONDecoder().decode(APIResponse.self, from: data)
                print("Response: \(String(describing: response))")
                print("Data: \(data)")
            }
        }.resume()
    }
    
    private static func JSONEncode(_ update: Update) -> Data? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(update)
            return jsonData
        } catch {
            print("Error encoding update \(update)")
            return nil
        }
    }
}
