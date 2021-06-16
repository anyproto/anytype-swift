import SwiftUI

struct FloaterWrapper<Content :View>: View {
    var onHide: () -> () = {}
    
    @State private var showSettings = false
    private let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Color.clear
            .ignoresSafeArea()
            .bottomFloater(isPresented: $showSettings) {
                content
            }
            .onChange(of: showSettings) { showSettings in
                if showSettings == false {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onHide()
                    }
                }
            }
            .onAppear {
                withAnimation(.ripple) {
                    showSettings = true
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
