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

/**
 * Singleton that tracks the evolution of all the active events
 * and pushed periodic updates to the server
 */
public class Owl {
    
    internal var events: [String:Event] = [:]
    internal var updates: [Update] = []
    internal var executor: PeriodicExecutor = PeriodicExecutor()
    internal static let shared = Owl()
    internal var enableDataSend = true
    
    private init() {
        executor.scheduleTask(publishUpdates, interval: PUBLISH_INTERVAL)
        // Initialize WebSocket connection here
    }
    
    /**
     * Returns a new event instance with the given event name
     */
    public static func newEvent(name: String) -> EventInstance {
        if shared.events.index(forKey: name) == nil {
            shared.events[name] = Event(name: name)
        }
        return shared.events[name]!.newInstance()
    }
    
    private func eventExists(_ eventName: String, _ id: UUID) -> Bool {
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
    internal func start(eventName: String, id: UUID) -> Bool {
        if !eventExists(eventName, id) {
            return false
        }
        let event = events[eventName]!.instances[id]!
        if !event.steps.isEmpty {
            print("event already ongoing")
            return false
        }
        
        let start = Step(name: "start", number: 0)
        event.steps.append(start)
        
        updates.append(StartUpdate(eventName: eventName, eventId: id, timestamp: start.time))
        
        return true
    }
    
    internal func step(eventName: String, id: UUID, stepName: String) -> Bool {
        if(!eventExists(eventName, id)) {
            return false
        }
        if DISSALLOWED_NAMES.contains(stepName) {
            print("The name \(eventName) is dissallowed as a step name. Aborting.")
            return false
        }

        guard let last = events[eventName]!.instances[id]!.steps.last else {
            print("Attempting to add a step without starting the event. Aborting.")
            return false
        }
        
        if last.name == "end" {
            print("Attempting to add a step after the event has ended. Aborting.")
            return false
        }
        
        let stepNumber = events[eventName]!.instances[id]!.steps.count
        let step = Step(name: stepName, number: stepNumber)
        events[eventName]!.instances[id]!.steps.append(step)
        
        updates.append(StepUpdate(eventName: eventName, eventId: id, name: stepName, number: stepNumber, timestamp: step.time))
        
        return true
    }
    
    internal func label(eventName: String, id: UUID, key: String,  val: Codable) -> Bool {
        if !eventExists(eventName, id) {
            return false
        }
        
        if events[eventName]!.instances[id]!.steps.last == nil {
            print("Attempting to add a label without starting the event. Aborting.")
            return false
        }
        events[eventName]!.instances[id]!.steps.last?.label(key: key, val: val)
        
        let lastStep = events[eventName]!.instances[id]!.steps.last!
        
        updates.append(LabelUpdate(eventName: eventName, eventId: id, stepName: lastStep.name, stepNumber: lastStep.number, key: key, val: val))
        
        return true
    }
    
    internal func end(eventName: String, id: UUID, result: Result) -> Bool {
        if !eventExists(eventName, id) {
            return false
        }
        
        let event = events[eventName]!.instances[id]!
        
        guard let lastStep = event.steps.last else {
            print("Attempting to close an event without starting it. Aborting.")
            return false
        }
        
        if lastStep.name == "end" {
            print("Event already ended. Aborting.")
            return false
        }
        
        let step = Step(name: "end", number: event.steps.count)
        step.label(key: "result", val: result.rawValue)
        event.steps.append(step)
        
        updates.append(EndUpdate(eventName: eventName, eventId: id, result: result, timestamp: step.time, stepNumber: step.number))
        
        return true
    }
    
    private func publishUpdates() {
        let updatesCount = min(MAX_CAPACITY, updates.count)
        if updatesCount == 0 {
            return
        }
        
        let encoder = JSONEncoder()
        var data: [[String: Any]] = []
        
        for _ in 1...updatesCount {
            let update = updates.removeFirst()
            do {
                let encodedUpdate = try encoder.encode(update)
                if let jsonObject = try JSONSerialization.jsonObject(with: encodedUpdate, options: []) as? [String: Any] {
                    data.append(jsonObject)
                }
            } catch {
                print("Error encoding update: \(error)")
                continue
            }
        }
        
        print("\n\ndata to send: \(data)\n\n")
        
        if enableDataSend {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                sendData(jsonData)
            } catch {
                print("Error serializing data array: \(data)")
            }
        }
        
    }
    
    private func sendData(_ data: Data) {
        let serverIP = "localhost"
        var request = URLRequest(url: URL(string: "http://\(serverIP):3030/receive")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
        URLSession.shared.dataTask(with: request) {data, response, error in
            if let error = error {
                print("Error sending request: \(error)")
                return
            }
            if let data = data {
                print("Response: \(String(describing: response))")
                print("Data: \(String(decoding: data, as: UTF8.self))")
            }
        }.resume()
    }
    
    internal static func disableDataSend() {
        shared.enableDataSend = false
    }
    
    internal static func clearUpdates() {
        Owl.shared.updates = []
    }
}
