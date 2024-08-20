import SwiftUI

struct SpaceHubCoordinatorView: View {
    @State private var showHome = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.Light.amber.ignoresSafeArea()
                StandardButton("Goto:// home", style: .primaryLarge) {
                    showHome.toggle()
                }.padding()
            }
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
