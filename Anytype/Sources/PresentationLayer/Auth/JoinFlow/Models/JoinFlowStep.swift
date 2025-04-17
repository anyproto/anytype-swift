enum JoinFlowStep: Int, CaseIterable {
    case key = 1
    case soul
    
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
        JoinFlowStep.allCases.first ?? .key
    }
    
    var isFirst: Bool {
        self == JoinFlowStep.allCases.first
    }
    
    var isLast: Bool {
        self == JoinFlowStep.allCases.last
    }
    
    static var totalCount: Int {
        JoinFlowStep.allCases.count
    }
}
