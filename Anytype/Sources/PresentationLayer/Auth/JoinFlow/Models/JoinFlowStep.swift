enum JoinFlowStep: Int, CaseIterable {
    case key = 1
    case soul
    case email
    
    var next: JoinFlowStep? {
        let nextStepNumber = rawValue + 1
        guard let nextStep = JoinFlowStep(rawValue: nextStepNumber) else {
            return nil
        }
        return nextStep
    }
    
    var previous: JoinFlowStep? {
        let previousStepNumber = rawValue - 1
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
}
