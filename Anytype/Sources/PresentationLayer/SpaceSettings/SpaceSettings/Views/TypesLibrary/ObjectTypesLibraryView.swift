import SwiftUI

struct ObjectTypesLibraryView: View {
    
    let spaceId: String
    
    @Environment(\.pageNavigation) private var pageNavigation
    
    var body: some View {
        ObjectTypeSearchView(title: Loc.objectTypes, spaceId: spaceId, settings: .library, style: .navbar) { type in
            pageNavigation.open(.editor(.type(EditorTypeObject(objectId: type.id, spaceId: type.spaceId))))
        }
        .homeBottomPanelHidden(true)
    }
}
