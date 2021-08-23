import SwiftUI

struct OverlayWaitingView<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    
    let presenting: Presenting
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting
                    .blur(radius: self.isShowing ? 2 : 0)
                    
                
                VStack() {
                    AnytypeText("Loading...", style: .uxBodyRegular)
                    ActivityIndicator(style: .large)
                }
                .frame(width: geometry.size.width * 0.8, height: geometry.size.height * 0.25)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
            }
        }
    }
}

struct OverlayWaitingView_Previews: PreviewProvider {
    static var previews: some View {
        let view = VStack() {
            AnytypeText("main screen", style: .uxBodyRegular)
        }
        return OverlayWaitingView(isShowing: .constant(true), presenting: view)
    }
}
