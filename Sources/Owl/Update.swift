import Foundation

class Update {
    private let eventName: String
    private let eventId: UUID
    
    init(eventName: String, eventId: UUID) {
        self.eventName = eventName
        self.eventId = eventId
    }
}

class StartUpdate: Update {
    override init(eventName: String, eventId: UUID) {
        super.init(eventName: eventName, eventId: eventId)
    }
}

class StepUpdate: Update {
    private let stepName: String
    
    init(eventName: String, eventId: UUID, stepName: String) {
        self.stepName = stepName
        super.init(eventName: eventName, eventId: eventId)
    }
}

class LabelUpdate: Update {
    private let stepName: String
    private let key: String
    private let val: Codable
    
    init(eventName: String, eventId: UUID, stepName: String, key: String, val: Codable) {
        self.stepName = stepName
        self.key = key
        self.val = val
        super.init(eventName: eventName, eventId: eventId)
    }
}

class StopUpdate: Update {
    private let result: Result
    
    init(eventName: String, eventId: UUID, result: Result) {
        self.result = result
        super.init(eventName: eventName, eventId: eventId)
    }
}
