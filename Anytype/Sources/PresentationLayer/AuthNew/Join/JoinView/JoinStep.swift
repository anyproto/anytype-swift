enum JoinStep: Int, CaseIterable {
    case key = 1
    case email
    case personaInfo
    case useCaseInfo
    
    var next: JoinStep? {
        let nextStepNumber = rawValue + 1
        guard let nextStep = JoinStep(rawValue: nextStepNumber) else {
            return nil
        }
        return nextStep
    }
    
    var previous: JoinStep? {
        let previousStepNumber = rawValue - 1
        guard let previousStep = JoinStep(rawValue: previousStepNumber) else {
            return nil
        }
        return previousStep
    }
    
    static var firstStep: JoinStep {
        JoinStep.allCases.first ?? .key
    }
}
