import Foundation

class Step {
    let name: String
    let time: Int64
    var labels: [String:Codable]
    
    init(_ name: String) {
        self.name = name
        self.time = Int64(CFAbsoluteTimeGetCurrent() * 1000)
        self.labels = [:]
    }
    
    func label(key: String, val: Codable) {
        self.labels[key] = val
    }
}
