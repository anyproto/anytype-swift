import SwiftUI

// https://github.com/Zi0P4tch0/Swift-UI-Views
struct Snackbar: View {

    @Binding var isShowing: Bool
    private let presenting: AnyView
    private let text: AnytypeText
    private let hideTimeout: Int
    
    init<Presenting>(
        isShowing: Binding<Bool>,
        presenting: Presenting,
        text: AnytypeText,
        hideTimeout: Int
    ) where Presenting: View {
        _isShowing = isShowing
        self.presenting = presenting.eraseToAnyView()
        self.text = text
        self.hideTimeout = hideTimeout
    }

    var body: some View {
        ZStack(alignment: .center) {
            presenting
            
            VStack {
                Spacer()
                if isShowing {
                    snackbarContainer
                        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .opacity))
                }
            }
            .animation(.spring(), value: isShowing)
        }
    }
    
    private var snackbarContainer: some View {
        HStack(spacing: 0) {
            Spacer()
            snackbar
            Spacer()
        }
        .offset(x: 0, y: -20)
        .onAppear { hideAfterTimeout() }
        .onChange(of: isShowing) { isShowing in
            if isShowing == true {
                hideAfterTimeout()
            }
        }
    }
    
    private func hideAfterTimeout() {
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(hideTimeout)) {
            self.isShowing = false
        }
    }
    
    private var snackbar: some View {
        HStack {
            Image.checked
            text
                .lineLimit(3)
        }
        .padding()
        .frame(minHeight: 64)
        .background(Color.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 7)
    }
    
}
