import Foundation

public class RandomEventGenerator {
    private var nEvents: Int
    private var events: [EventInstance]
    
    public init(nEvents: Int? = nil) {
        if nEvents != nil {
            self.nEvents = nEvents!
        } else {
            self.nEvents = Int.random(in: 5..<11)
        }
        self.events = []
    }

    public func run() {
        generateEvents()
        generateStepsAndLabels()
        closeEvents()
        
        print("Sleeping to let events being sent to the server...")
        Thread.sleep(forTimeInterval: 60)
    }
    
    private func generateEvents() {
        print("Generating events...")
        for i in 0..<nEvents {
            let id = Int.random(in: 1..<nEvents)
            let eventName = "event#" + String(id)
            let event = Owl.newEvent(name: eventName)
            if event.start() {
                events.append(event)
            }
        }
        nEvents = events.count
        print("\(nEvents) generated.")
    }
    
    private func generateStepsAndLabels() {
        print("Generating steps and labels...")
        for i in 0..<100 {
            // Choose a random event
            guard let event = events.randomElement() else {
                continue
            }
            
            // Generate steps
            let stepName = "step#" + String(Int.random(in: 1..<100))
            event.step(stepName)
            
            // Generate Labels
            for i in 0..<3 {
                let id = Int.random(in: 1..<10)
                let key = "key#" + String(id)
                let val = "val#" + String(id)
                event.label(key: key, val: val)
            }
        }
        print("Steps and labels generated.")
    }
    
    private func closeEvents() {
        print("Closing events...")
        for event in events {
            event.end(result: Result.allCases.randomElement()!)
        }
        print("Events closed!")
    }
}
