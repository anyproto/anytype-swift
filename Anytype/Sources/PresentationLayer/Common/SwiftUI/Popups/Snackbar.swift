import SwiftUI

// https://github.com/Zi0P4tch0/Swift-UI-Views
struct Snackbar: View {

    @Binding var isShowing: Bool
    private let presenting: AnyView
    private let text: AnytypeText

    init<Presenting>(
        isShowing: Binding<Bool>,
        presenting: Presenting,
        text: AnytypeText
    ) where Presenting: View {
        _isShowing = isShowing
        self.presenting = presenting.eraseToAnyView()
        self.text = text
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting
                VStack {
                    Spacer()
                    if isShowing {
                        snackbar(width: geometry.readableAlertWidth)
                            .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                    }
                }
                .animation(.spring(), value: isShowing)
            }
        }
    }
    
    private func snackbar(width: CGFloat) -> some View {
        HStack {
            Image.checked
            text
        }
        .padding()
        .frame(width: width, height: 64)
        .background(Color.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 7)
        .offset(x: 0, y: -20)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.isShowing = false
            }
        }
    }
    
}
