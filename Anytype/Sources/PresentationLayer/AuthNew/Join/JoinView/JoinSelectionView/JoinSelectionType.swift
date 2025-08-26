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
                InfoSelectionOption(icon: .SelectionOption.Persona.student, title: Loc.Auth.JoinFlow.SelectionOption.Persona.student),
                InfoSelectionOption(icon: .SelectionOption.Persona.manager, title: Loc.Auth.JoinFlow.SelectionOption.Persona.manager),
                InfoSelectionOption(icon: .SelectionOption.Persona.developer, title: Loc.Auth.JoinFlow.SelectionOption.Persona.developer),
                InfoSelectionOption(icon: .SelectionOption.Persona.designer, title: Loc.Auth.JoinFlow.SelectionOption.Persona.designer),
                InfoSelectionOption(icon: .SelectionOption.Persona.writer, title: Loc.Auth.JoinFlow.SelectionOption.Persona.writer),
                InfoSelectionOption(icon: .SelectionOption.Persona.marketer, title: Loc.Auth.JoinFlow.SelectionOption.Persona.marketer),
                InfoSelectionOption(icon: .SelectionOption.Persona.artist, title: Loc.Auth.JoinFlow.SelectionOption.Persona.artist),
                InfoSelectionOption(icon: .SelectionOption.Persona.consultunt, title: Loc.Auth.JoinFlow.SelectionOption.Persona.consultant),
                InfoSelectionOption(icon: .SelectionOption.Persona.entrepreneur, title: Loc.Auth.JoinFlow.SelectionOption.Persona.entrepreneur),
                InfoSelectionOption(icon: .SelectionOption.Persona.scientist, title: Loc.Auth.JoinFlow.SelectionOption.Persona.researcher),
                InfoSelectionOption(icon: .SelectionOption.other, title: Loc.other)
            ]
        case .useCase:
            return [
                InfoSelectionOption(icon: .SelectionOption.UseCase.messaging, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.messaging),
                InfoSelectionOption(icon: .SelectionOption.UseCase.knowledge, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.knowledge),
                InfoSelectionOption(icon: .SelectionOption.UseCase.notes, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.notes),
                InfoSelectionOption(icon: .SelectionOption.UseCase.projects, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.projects),
                InfoSelectionOption(icon: .SelectionOption.UseCase.lifePlanning, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.lifePlanning),
                InfoSelectionOption(icon: .SelectionOption.UseCase.habitTracking, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.habitTracking),
                InfoSelectionOption(icon: .SelectionOption.UseCase.teamWork, title:  Loc.Auth.JoinFlow.SelectionOption.UseCase.teamWork),
                InfoSelectionOption(icon: .SelectionOption.other, title: Loc.other)
            ]
        }
    }
}
