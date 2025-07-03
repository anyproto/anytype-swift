import SwiftUI

struct HomeView: View {
    private weak var output: (any SpaceHubModuleOutput)?
    
    @State private var selectedIndex: Int = 0
    
    init(output: (any SpaceHubModuleOutput)?) {
        self.output = output
    }
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            OldSpaceHubView(output: output)
                .tabItem {
                    Image(systemName: "square.3.layers.3d.top.filled")
                }
                .tag(0)
            
            SpaceHubView(output: output)
                .tabItem {
                    Image(systemName: "ellipsis.message.fill")
                }
                .tag(1)
            
            SettingsCoordinatorView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                }
                .tag(2)
        }
        .tint(Color.Text.primary)
    }
}

#Preview {
    HomeView(output: nil)
}
