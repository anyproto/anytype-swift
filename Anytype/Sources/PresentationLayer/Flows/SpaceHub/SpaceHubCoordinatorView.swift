import SwiftUI

struct SpaceHubCoordinatorView: View {
    @State private var showHome = false
    
    var body: some View {
        NavigationStack {
            SpaceHubView { showHome.toggle() }
                .navigationDestination(isPresented: $showHome) {
                    HomeCoordinatorView(showHome: $showHome)
                        .navigationBarBackButtonHidden()
                }
        }
    }
}

#Preview {
    SpaceHubCoordinatorView()
}
