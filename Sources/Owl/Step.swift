import Foundation

class Step {
    let name: String
    let time: Int64
    let number: Int
    var labels: [String:Codable]
    
    init(name: String, number: Int) {
        self.time = Int64(CFAbsoluteTimeGetCurrent() * 1000)
        self.name = name
        self.number = number
        self.labels = [:]
    }
    
    func label(key: String, val: Codable) {
        self.labels[key] = val
    }
}
