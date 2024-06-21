import Services

extension DataviewViewSize {
    var value: String {
        if isSmall {
            return Loc.Set.View.Settings.CardSize.Small.title
        } else {
            return Loc.Set.View.Settings.CardSize.Large.title
        }
    }
    
    var isSmall: Bool {
        switch self {
        case .small, .medium:
            return true
        case .large, .UNRECOGNIZED(_):
            return false
        }
    }
    
    static let availableCases = [DataviewViewSize.small, DataviewViewSize.large]
}

extension DataviewView {
    var isSmallCardSize: Bool {
        cardSize.isSmall
    }
}
