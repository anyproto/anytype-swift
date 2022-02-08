import SwiftUI

struct ErrorAlertView<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    var errorText: String
    
    let presenting: Presenting
    let onOkPressed: () -> ()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting.blur(radius: self.isShowing ? 1 : 0)
                
                VStack() {
                    AnytypeText(self.errorText, style: .body, color: .textPrimary)
                        .padding()
                        .layoutPriority(1)
                    
                    
                    VStack(spacing: 0) {
                        Divider().background(Color.strokePrimary)
                        Button(action: {
                            isShowing.toggle()
                            onOkPressed()
                        }) {
                            AnytypeText("Ok", style: .body, color: .buttonAccent)
                                .padding()
                        }
                    }
                }
                .frame(maxWidth: maxWidth(using: geometry.size.width), minHeight: 0)
                .background(Color.backgroundSecondary)
                .cornerRadius(10)
                .transition(.slide)
                .shadow(color: Color.shadowPrimary, radius: 4)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
    
    func maxWidth(using width: CGFloat) -> CGFloat {
        if UIDevice.isPad {
            if UIDevice.current.orientation.isLandscape {
                return width * 0.3
            } else {
                return width * 0.4
            }
            
        } else {
            return width * 0.8
        }
    }
}

struct ErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        let view = VStack {
            AnytypeText("ParentView", style: .body, color: .textPrimary)
        }
        return ErrorAlertView(isShowing: .constant(true), errorText: "Some Error long very long long long error", presenting: view, onOkPressed: {})
    }
}
