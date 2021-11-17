import SwiftUI

struct FloaterWrapper<Content :View>: View {
    var onHide: () -> () = {}
    
    @State private var showFloater = false
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .bottomFloater(isPresented: $showFloater) {
                content
            }
            .onChange(of: showFloater) { showSettings in
                if showFloater == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onHide()
                    }
                }
            }
            .onAppear {
                withAnimation(.fastSpring) {
                    showFloater = true
                }
            }
    }
}

struct FloaterWrapper_Previews: PreviewProvider {
    static var previews: some View {
        FloaterWrapper() {
            Text("FOOOO")
        }
    }
}
