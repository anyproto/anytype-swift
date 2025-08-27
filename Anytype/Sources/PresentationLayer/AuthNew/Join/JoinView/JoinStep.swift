enum JoinStep: Int, CaseIterable {
    case email = 1
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
        JoinStep.allCases.first ?? .email
    }
}
