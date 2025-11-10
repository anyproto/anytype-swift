import SwiftUI

struct SpaceHubSearchEmptySpaceView: View {
    
    var body: some View {
        HomeUpdateSubmoduleView().padding(8)
        VStack {
            Spacer(minLength: 100)
            EmptyStateView(
                title: Loc.noMatchesFound,
                subtitle: "",
                style: .withImage,
                buttonData: nil
            )
            Spacer()
        }
    }
}
