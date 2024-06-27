import Foundation
import SwiftUI

struct HomeUpdateView: View, Animatable {
    
    @State private var locationState = CGFloat(0)
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(Loc.Widgets.appUpdate)
                .anytypeStyle(.previewTitle2Medium)
                .foregroundColor(.Text.primary)
                .padding(.horizontal, 46)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            Image(asset: .X18.updateApp)
                .foregroundColor(.Text.primary)
                .padding(.horizontal, 16)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4).delay(0.5)) {
                locationState = 6
            }
        }
        .background {
            HomeUpdateGradient(locationState: locationState)
        }
        .cornerRadius(10, style: .continuous)
        .colorScheme(.light)
    }
}

struct HomeUpdatePreviewView: View {
    
    // Update id for initiate onAppea
    @State private var id = UUID()
    
    var body: some View {
        VStack(spacing: 40) {
            HomeUpdateView()
                .padding(.horizontal, 10)
                .id(id)
            Button("Animation") {
                id = UUID()
            }
        }
    }
}

#Preview {
    HomeUpdatePreviewView()
}
