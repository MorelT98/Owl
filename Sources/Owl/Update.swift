import Foundation

fileprivate enum UpdateFields: String, CodingKey {
    case updateType
    case eventName
    case eventId
    case stepName
    case stepTime
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
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: UpdateFields.self)
        try container.encode(UpdateTypes.start.rawValue, forKey: .updateType)
        try container.encode(eventName, forKey: .eventName)
        try container.encode(eventId, forKey: .eventId)
    }
}

class StepUpdate: Update {
    internal let stepName: String
    internal let stepTime: Int64
    
    init(eventName: String, eventId: UUID, stepName: String, stepTime: Int64) {
        self.stepName = stepName
        self.stepTime = stepTime
        super.init(eventName: eventName, eventId: eventId)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: UpdateFields.self)
        try container.encode(UpdateTypes.step.rawValue, forKey: .updateType)
        try container.encode(self.eventName, forKey: .eventName)
        try container.encode(self.eventId, forKey: .eventId)
        try container.encode(self.stepName, forKey: .stepName)
        try container.encode(self.stepTime, forKey: .stepTime)
    }
}

class LabelUpdate: Update {
    internal let stepName: String
    internal let key: String
    internal let val: Codable
    
    init(eventName: String, eventId: UUID, stepName: String, key: String, val: Codable) {
        self.stepName = stepName
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
        try container.encode(self.key, forKey: .labelKey)
        try container.encode(self.val, forKey: .labelVal)
    }
}

class EndUpdate: Update {
    internal let result: Result
    
    init(eventName: String, eventId: UUID, result: Result) {
        self.result = result
        super.init(eventName: eventName, eventId: eventId)
    }
    
    override func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: UpdateFields.self)
        try container.encode(UpdateTypes.end.rawValue, forKey: .updateType)
        try container.encode(self.eventName, forKey: .eventName)
        try container.encode(self.eventId, forKey: .eventId)
        try container.encode(self.result.rawValue, forKey: .result)
    }
}
