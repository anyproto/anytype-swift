import SwiftUI


struct ShowViewFramesKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var showViewFrames: Bool {
        get {
            self[ShowViewFramesKey.self]
        }
        set {
            self[ShowViewFramesKey.self] = newValue
        }
    }
}


struct AddedScrollViewOffsetKey: EnvironmentKey {
    static let defaultValue: CGPoint = .zero
}

extension EnvironmentValues {
    var addedScrollViewOffset: CGPoint {
        get {
            self[AddedScrollViewOffsetKey.self]
        }
        set {
            self[AddedScrollViewOffsetKey.self] = newValue
        }
    }
}


struct TimingTimerKey: EnvironmentKey {
    static let defaultValue: TimingTimer = TimingTimer()
}

extension EnvironmentValues {
    var timingTimer: TimingTimer {
        get {
            self[TimingTimerKey.self]
        }
        set {
            self[TimingTimerKey.self] = newValue
        }
    }
}
