import Services


extension DebugRunProfilerState {
    var text: String {
        switch self {
        case .empty, .done:
            "Run debug profiler 🤓"
        case .inProgress:
            "Profiling in progress ..."
        }
    }
}
