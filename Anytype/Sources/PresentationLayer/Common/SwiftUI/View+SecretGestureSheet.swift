import SwiftUI
import AudioToolbox

struct SecretGestureSheetModifier: ViewModifier {
  
    @State private var titleTapCount = 0
    @State private var showSheet = false
    
    private let contentView: () -> AnyView?
    
    init(contentView: @escaping () -> AnyView?) {
        self.contentView = contentView
    }
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                titleTapCount += 1
                if titleTapCount == 10 {
                    titleTapCount = 0
                    AudioServicesPlaySystemSound(1109)
                    showSheet.toggle()
                }
            }
            .sheet(isPresented: $showSheet) {
                contentView()
            }
    }
}


extension View {
    func secretGestureSheet(_ contentView: @escaping () -> AnyView?) -> some View {
        return self.modifier(SecretGestureSheetModifier(contentView: contentView))
    }
}
