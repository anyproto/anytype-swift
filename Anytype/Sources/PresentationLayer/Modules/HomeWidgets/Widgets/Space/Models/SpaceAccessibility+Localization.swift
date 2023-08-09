import Foundation
import Services

extension SpaceAccessibility {
    var name: String {
        switch self {
        case .private:
            return Loc.Spaces.Accessibility.private
        case .public:
            return Loc.Spaces.Accessibility.public
        }
    }
    
    var fullName: String {
        switch self {
        case .private:
            return Loc.Spaces.Accessibility.privateFull
        case .public:
            return Loc.Spaces.Accessibility.publicFull
        }
    }
}
