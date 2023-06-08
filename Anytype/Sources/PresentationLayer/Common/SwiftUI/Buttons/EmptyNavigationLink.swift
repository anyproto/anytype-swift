import SwiftUI

extension View {
    
    func addEmptyNavigationLink<Destination: View>(destination: Destination, isActive: Binding<Bool>) -> some View {
        self.overlay(
            NavigationLink(destination: destination, isActive: isActive) {
                EmptyView()
            }.frame(width: 0, height: 0)
        )
    }
}
