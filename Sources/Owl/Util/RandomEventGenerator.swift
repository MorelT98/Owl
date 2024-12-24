import Foundation

// Generates a bunch of events by:
// - Creating the events with random event names
// - For each event, it creates a random
public class RandomEventGenerator {
    private var nEvents: Int
    private var maxNStepsPerEvent: Int
    private var maxNLabelsPerStep: Int
    private var events: [EventInstance]
    
    public init(nEvents: Int = 10, maxNStepsPerEvent: Int = 10, maxNLabelsPerStep: Int = 10) {
        self.nEvents = nEvents
        self.maxNStepsPerEvent = maxNStepsPerEvent
        self.maxNLabelsPerStep = maxNLabelsPerStep
        self.events = []
    }

    public func run() {
        generateEvents()
        generateSteps()
        closeEvents()
        
        print("Sleeping to let events being sent to the server...")
        Thread.sleep(forTimeInterval: 60 * 1000)
    }
    
    private func generateEvents() {
        print("Generating events...")
        for i in 0..<nEvents {
            
            // Choose a random event to create
            // Note that this means multiple events of the
            // same name can be created
            let id = Int.random(in: 1..<nEvents)
            let eventName = "event_" + String(id)
            let event = Owl.newEvent(name: eventName)
            
            // Add some delay so that not all the events
            // start at the same time
            Thread.sleep(forTimeInterval: TimeInterval(Int.random(in: 1...10)))
            
            if event.start() {
                events.append(event)
            }
        }
        nEvents = events.count
        print("\(nEvents) generated.")
    }
    
    private func generateSteps() {
        print("Generating steps and labels...")
        for i in 0..<nEvents {
            // Pick a number of steps for the current events
            let nSteps = Int.random(in: 0...maxNStepsPerEvent)
            
            // generate the steps
            for _ in 0..<nSteps {
                // wait a bit
                Thread.sleep(forTimeInterval: TimeInterval(Int.random(in: 1...5)))
                
                // Multiple steps can have the same name
                // (but they will have different step numbers)
                let stepName = "step_" + String(Int.random(in: 0...nSteps))
                events[i].step(stepName)
                
                // generate labels
                generateLabels(for: events[i])
            }
        }
        print("Steps and labels generated.")
    }
    
    private func generateLabels(for event: EventInstance) {
        // Pick a number of labels for the current event
        let nLabels = Int.random(in: 0...maxNLabelsPerStep)
        
        // generate labels
        for _ in 0..<nLabels {
            let i = Int.random(in: 0...nLabels)
            let key = "key_" + String(i)
            let val = "val_" + String(i)
            event.label(key: key, val: val)
        }
    }
    
    private func closeEvents() {
        print("Closing events...")
        for event in events {
            event.end(result: Result.allCases.randomElement()!)
        }
        print("Events closed!")
    }
}
