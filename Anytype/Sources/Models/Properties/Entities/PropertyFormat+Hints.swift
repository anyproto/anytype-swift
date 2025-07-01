import Services

extension PropertyFormat {
    var hint: String {
        switch self {
        case .longText:
            return Loc.enterText
        case .shortText:
            return Loc.enterText
        case .number:
            return Loc.enterNumber
        case .date:
            return Loc.selectDate
        case .url:
            return Loc.addLink
        case .email:
            return Loc.addEmail
        case .phone:
            return Loc.addPhone
        case .status:
            return Loc.selectOption
        case .tag:
            return Loc.selectOptions
        case .file:
            return Loc.selectFile
        case .object:
            return Loc.selectObject
        case .checkbox:
            return ""
        case .unrecognized:
            return Loc.enterValue
        }
    }
    
}
