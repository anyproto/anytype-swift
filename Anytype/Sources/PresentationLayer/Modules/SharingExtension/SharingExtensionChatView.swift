import SwiftUI

struct SharingExtensionChatView: View {
    
    let spaces: [SpaceView]
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Spaces \(spaces.count)")
                Text("2")
            }
        }
    }
}
