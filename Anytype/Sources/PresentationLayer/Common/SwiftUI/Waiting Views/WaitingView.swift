import SwiftUI

struct WaitingView: View {
    let text: String
    @Binding var showError: Bool
    @Binding var errorText: String
    
    var onErrorTap: (() -> ())
    
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        ZStack {
            Gradients.authBackground()
            VStack() {
                Spacer()
                VStack(spacing: 16) {
                    if showError {
                        errorView
                    } else {
                        loadingAnimation.padding(.top, 16)
                        AnytypeText(text, style: .heading)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.background)
                .cornerRadius(16.0)
            }
            .padding(20)
        }
        .navigationBarHidden(true)
    }
    
    private var errorView: some View {
        Group {
            AnytypeText(errorText, style: .heading)
                .padding(.top, -10)
                .transition(.opacity)
            
            StandardButton(disabled: false, text: "Ok", style: .secondary) {
                presentationMode.wrappedValue.dismiss()
                onErrorTap()
            }
            .transition(.opacity)
        }
    }
    
    @State private var shouldAnimate = false
    private var loadingAnimation: some View {
        HStack(alignment: .center) {
            Circle()
                .fill(shouldAnimate ? Color.stroke : Color.grayscale10)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(
                    Animation.easeInOut(duration: 0.5).repeatForever(),
                    value: shouldAnimate
                )
            Circle()
                .fill(shouldAnimate ? Color.stroke : Color.grayscale10)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(
                    Animation.easeInOut(duration: 0.5).repeatForever().delay(0.3),
                    value: shouldAnimate
                )
            Circle()
                .fill(shouldAnimate ? Color.stroke : Color.grayscale10)
                .frame(width: 20, height: 20)
                .scaleEffect(shouldAnimate ? 1.0 : 0.5)
                .animation(
                    Animation.easeInOut(duration: 0.5).repeatForever().delay(0.6),
                    value: shouldAnimate
                )
        }
        .onAppear {
            shouldAnimate = true
        }
    }
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView(text: "Setting up the wallet…", showError: .constant(false), errorText: .constant("Some error happens"), onErrorTap: {})
    }
}
