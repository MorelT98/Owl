import Foundation

class PeriodicExecutor {
    private let queue: DispatchQueue
    private var timer: DispatchSourceTimer?
    
    init(queue: DispatchQueue = .global(qos: .default)) {
        self.queue = queue
    }
    
    func scheduleTask(_ task: @escaping () -> Void, interval: TimeInterval) {
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(deadline: .now() + interval, repeating: interval)
        timer?.setEventHandler(handler: task)
        timer?.resume()
    }
    
    func cancel() {
        timer?.cancel()
    }
}
