import Foundation

@MainActor
final class HangedObjectsMonitor {

    private(set) var objectsCount: Int = 0
    private var startTime: Date?
    private var timer: Task<Void, Never>?
    private var shouldShowState: Bool = false

    var onStateChanged: (() -> Void)?

    func update(count: Int) {
        objectsCount = count

        if count > 0 {
            if startTime == nil {
                startTime = Date()
                startTimer()
            }
        } else {
            reset()
        }
    }

    func reset() {
        startTime = nil
        timer?.cancel()
        timer = nil
        if shouldShowState {
            shouldShowState = false
            onStateChanged?()
        }
    }

    func shouldShow() -> Bool {
        shouldShowState
    }

    private func startTimer() {
        timer?.cancel()
        timer = Task { [weak self] in
            while !Task.isCancelled {
                guard let self, let startTime = self.startTime else {
                    return
                }

                let elapsed = Date().timeIntervalSince(startTime)
                let shouldShow = elapsed > 60

                if self.shouldShowState != shouldShow {
                    self.shouldShowState = shouldShow
                    self.onStateChanged?()
                }

                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
}
