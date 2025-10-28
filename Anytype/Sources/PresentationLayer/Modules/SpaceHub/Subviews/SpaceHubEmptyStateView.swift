import SwiftUI

struct SpaceHubEmptyStateView: View {
    
    let onTapCreateSpace: () -> Void
    
    var body: some View {
        HomeUpdateSubmoduleView().padding(8)
        EmptyStateView(
            title: Loc.thereAreNoSpacesYet,
            subtitle: "",
            style: .withImage,
            buttonData: EmptyStateView.ButtonData(title: Loc.createSpace) {
                onTapCreateSpace()
            }
        )
    }
}
