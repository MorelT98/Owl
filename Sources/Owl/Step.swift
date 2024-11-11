import Foundation

class Step {
    let name: String
    var labels: [String:Codable]
    
    init(_ name: String) {
        self.name = name
        self.labels = ["time_ms":Date().timeIntervalSince1970 * 1000]
    }
    
    func label(key: String, val: Codable) {
        self.labels[key] = val
    }
}
