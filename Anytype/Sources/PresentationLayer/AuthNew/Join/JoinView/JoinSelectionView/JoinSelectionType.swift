enum JoinSelectionType {
    case persona
    case useCase
    
    var title: String {
        switch self {
        case .persona:
            return Loc.Auth.JoinFlow.PersonaInfo.title
        case .useCase:
            return Loc.Auth.JoinFlow.UseCaseInfo.title
        }
    }
    
    var description: String {
        switch self {
        case .persona:
            return Loc.Auth.JoinFlow.PersonaInfo.description
        case .useCase:
            return Loc.Auth.JoinFlow.UseCaseInfo.description
        }
    }
    
    var isMultiSelection: Bool {
        return false
    }
    
    var oprions: [InfoSelectionOption] {
        switch self {
        case .persona:
            return [
                InfoSelectionOption(icon: .SelectionOption.Persona.student, title: Loc.Auth.JoinFlow.SelectionOption.Persona.student, analyticsValue: "Student"),
                InfoSelectionOption(icon: .SelectionOption.Persona.manager, title: Loc.Auth.JoinFlow.SelectionOption.Persona.manager, analyticsValue: "Manager"),
                InfoSelectionOption(icon: .SelectionOption.Persona.developer, title: Loc.Auth.JoinFlow.SelectionOption.Persona.developer, analyticsValue: "SoftwareDeveloper"),
                InfoSelectionOption(icon: .SelectionOption.Persona.designer, title: Loc.Auth.JoinFlow.SelectionOption.Persona.designer, analyticsValue: "Designer"),
                InfoSelectionOption(icon: .SelectionOption.Persona.writer, title: Loc.Auth.JoinFlow.SelectionOption.Persona.writer, analyticsValue: "Writer"),
                InfoSelectionOption(icon: .SelectionOption.Persona.marketer, title: Loc.Auth.JoinFlow.SelectionOption.Persona.marketer, analyticsValue: "Marketer"),
                InfoSelectionOption(icon: .SelectionOption.Persona.artist, title: Loc.Auth.JoinFlow.SelectionOption.Persona.artist, analyticsValue: "Artist"),
                InfoSelectionOption(icon: .SelectionOption.Persona.consultunt, title: Loc.Auth.JoinFlow.SelectionOption.Persona.consultant, analyticsValue: "Consultant"),
                InfoSelectionOption(icon: .SelectionOption.Persona.entrepreneur, title: Loc.Auth.JoinFlow.SelectionOption.Persona.entrepreneur, analyticsValue: "Entrepreneur"),
                InfoSelectionOption(icon: .SelectionOption.Persona.scientist, title: Loc.Auth.JoinFlow.SelectionOption.Persona.researcher, analyticsValue: "Researcher"),
                InfoSelectionOption(icon: .SelectionOption.other, title: Loc.other, analyticsValue: "Other")
            ]
        case .useCase:
            return [
                InfoSelectionOption(icon: .SelectionOption.UseCase.messaging, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.messaging, analyticsValue: "Messaging"),
                InfoSelectionOption(icon: .SelectionOption.UseCase.knowledge, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.knowledge, analyticsValue: "Knowledge"),
                InfoSelectionOption(icon: .SelectionOption.UseCase.notes, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.notes, analyticsValue: "NoteTaking"),
                InfoSelectionOption(icon: .SelectionOption.UseCase.projects, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.projects, analyticsValue: "Projects"),
                InfoSelectionOption(icon: .SelectionOption.UseCase.lifePlanning, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.lifePlanning, analyticsValue: "LifePlanning"),
                InfoSelectionOption(icon: .SelectionOption.UseCase.habitTracking, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.habitTracking, analyticsValue: "HabitTracking"),
                InfoSelectionOption(icon: .SelectionOption.UseCase.teamWork, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.teamWork, analyticsValue: "TeamWork"),
                InfoSelectionOption(icon: .SelectionOption.other, title: Loc.other, analyticsValue: "Other")
            ]
        }
    }
    
    var analyticsStep: ClickOnboardingStep {
        switch self {
        case .persona: return .persona
        case .useCase: return .useCase
        }
    }
}
