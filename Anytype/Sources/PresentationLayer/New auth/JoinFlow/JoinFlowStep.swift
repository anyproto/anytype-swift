enum JoinFlowStep: Int, CaseIterable {
    case void = 1
    case key
    case soul
    case creatingSoul
    
    var next: JoinFlowStep? {
        let nextStepNumber = self.rawValue + 1
        guard let nextStep = JoinFlowStep(rawValue: nextStepNumber) else {
            return nil
        }
        return nextStep
    }
    
    var previous: JoinFlowStep? {
        let previousStepNumber = self.rawValue - 1
        guard let previousStep = JoinFlowStep(rawValue: previousStepNumber) else {
            return nil
        }
        return previousStep
    }
    
    static var firstStep: JoinFlowStep {
        JoinFlowStep.allCases.first ?? .void
    }
    
    var isFirst: Bool {
        self == JoinFlowStep.allCases.first
    }
    
    var isLast: Bool {
        self == JoinFlowStep.allCases.last
    }
    
    static var totalCount: Int {
        JoinFlowStep.allCases.filter { $0.countableStep }.count
    }
    
    private var countableStep: Bool {
        switch self {
        case .creatingSoul:
            return false
        case .void, .key, .soul:
            return true
        }
    }
}
