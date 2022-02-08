import SwiftUI

struct RelationSheetModifier: ViewModifier {
    
    @Binding var isPresented: Bool
    
    let title: String?
    let dismissCallback: (() -> ())?
    
    @State private var backgroundOpacity = 0.0
    @State private var sheetHeight = 0.0
    
    func body(content: Content) -> some View {
        ZStack {
            background
            
            VStack(spacing: 0) {
                Spacer()
                sheet(with: content)
            }
        }
        .ignoresSafeArea(.container)
        .onAppear {
            withAnimation(.fastSpring) {
                backgroundOpacity = 0.25
                isPresented = true
            }
        }
        .onChange(of: isPresented) { newValue in
            guard newValue == false else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                dismissCallback?()
            }
        }
    }
    
    private var background: some View {
        Color.strokePrimary.opacity(backgroundOpacity)
            .onTapGesture {
                withAnimation(.fastSpring) {
                    backgroundOpacity = 0.0
                    isPresented = false
                }
            }
    }
    
    private func sheet(with content: Content) -> some View {
        VStack(spacing: 0) {
            DragIndicator(bottomPadding: 0)
            
            if let title = title {
                AnytypeText(title, style: .uxTitle1Semibold, color: .textPrimary)
                    .padding([.top, .bottom], 12)
            }
            
            content
            
            Spacer.fixedHeight(20)
        }
        .background(Color.backgroundPrimary)
        .readSize { sheetHeight = $0.height }
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .offset(x: 0, y: currentOffset)
    }
    
    private var currentOffset: CGFloat {
        isPresented ? 0 : sheetHeight
    }
}

struct RelationSheetModifier_Previews: PreviewProvider {
    static var previews: some View {
        AnytypeText("text", style: .body, color: .red)
            .modifier(RelationSheetModifier(isPresented: .constant(true), title: "tiel", dismissCallback: nil))
    }
}

