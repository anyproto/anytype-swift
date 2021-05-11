import SwiftUI

struct ErrorAlertView<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    var errorText: String
    
    let presenting: Presenting
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                self.presenting.blur(radius: self.isShowing ? 1 : 0)
                
                VStack() {

                    AnytypeText(self.errorText, style: .body)
                        .foregroundColor(Color.white)
                        .padding()
                        .layoutPriority(1)
                    
                    
                    VStack(spacing: 0) {
                        Divider().background(Color.white)
                        Button(action: {
                            self.isShowing.toggle()
                        }) {
                            AnytypeText("Ok", style: .body)
                                .foregroundColor(Color("GrayText"))
                                .padding()
                        }
                    }
                }
                .frame(maxWidth: geometry.size.width * 0.8, minHeight: 0)
                .background(Color("BrownMenu"))
                .cornerRadius(10)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }
}

#if DEBUG
struct ErrorAlertView_Previews: PreviewProvider {
    static var previews: some View {
        let view = VStack {
            AnytypeText("ParentView", style: .body)
        }
        return ErrorAlertView(isShowing: .constant(true), errorText: "Some Error long very long long long error", presenting: view)
    }
}
#endif
