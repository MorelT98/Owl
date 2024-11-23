import Foundation

fileprivate enum UpdateFields: String, CodingKey {
    case updateType
    case eventName
    case eventId
    case stepName
    case stepNumber
    case timestamp
    case labelKey
    case labelVal
    case result
}

fileprivate enum UpdateTypes: String {
    case start
    case step
    case label
    case end
    case other
}

class Update: Encodable {
    internal let eventName: String
    internal let eventId: UUID
    
    init(eventName: String, eventId: UUID) {
        self.eventName = eventName
        self.eventId = eventId
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: UpdateFields.self)
        try container.encode(UpdateTypes.other.rawValue, forKey: .updateType)
        try container.encode(eventName, forKey: .eventName)
        try container.encode(eventId, forKey: .eventId)
    }
}

class StartUpdate: Update {
    internal let timestamp: Int64
    
    init(eventName: String, eventId: UUID, timestamp: Int64) {
        self.timestamp = timestamp
        super.init(eventName: eventName, eventId: eventId)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: UpdateFields.self)
        try container.encode(UpdateTypes.start.rawValue, forKey: .updateType)
        try container.encode(eventName, forKey: .eventName)
        try container.encode(eventId, forKey: .eventId)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

class StepUpdate: Update {
    internal let stepName: String
    internal let stepTime: Int64
    internal let stepNumber: Int
    
    init(eventName: String, eventId: UUID, stepName: String, stepNumber: Int, stepTime: Int64) {
        self.stepName = stepName
        self.stepNumber = stepNumber
        self.stepTime = stepTime
        super.init(eventName: eventName, eventId: eventId)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: UpdateFields.self)
        try container.encode(UpdateTypes.step.rawValue, forKey: .updateType)
        try container.encode(self.eventName, forKey: .eventName)
        try container.encode(self.eventId, forKey: .eventId)
        try container.encode(self.stepName, forKey: .stepName)
        try container.encode(self.stepTime, forKey: .timestamp)
        try container.encode(self.stepNumber, forKey: .stepNumber)
    }
}

class LabelUpdate: Update {
    internal let stepName: String
    internal let stepNumber: Int
    internal let key: String
    internal let val: Codable
    
    init(eventName: String, eventId: UUID, stepName: String, stepNumber: Int, key: String, val: Codable) {
        self.stepName = stepName
        self.stepNumber = stepNumber
        self.key = key
        self.val = val
        super.init(eventName: eventName, eventId: eventId)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: UpdateFields.self)
        try container.encode(UpdateTypes.label.rawValue, forKey: .updateType)
        try container.encode(self.eventName, forKey: .eventName)
        try container.encode(self.eventId, forKey: .eventId)
        try container.encode(self.stepName, forKey: .stepName)
        try container.encode(self.stepNumber, forKey: .stepNumber)
        try container.encode(self.key, forKey: .labelKey)
        try container.encode(self.val, forKey: .labelVal)
    }
}

class EndUpdate: Update {
    internal let result: Result
    internal let timestamp: Int64
    internal let stepNumber: Int
    
    init(eventName: String, eventId: UUID, result: Result, timestamp: Int64, stepNumber: Int) {
        self.result = result
        self.timestamp = timestamp
        self.stepNumber = stepNumber
        super.init(eventName: eventName, eventId: eventId)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: UpdateFields.self)
        try container.encode(UpdateTypes.end.rawValue, forKey: .updateType)
        try container.encode(self.eventName, forKey: .eventName)
        try container.encode(self.eventId, forKey: .eventId)
        try container.encode(self.result.rawValue, forKey: .result)
        try container.encode(self.timestamp, forKey: .timestamp)
        try container.encode(self.stepNumber, forKey: .stepNumber)
    }
}
