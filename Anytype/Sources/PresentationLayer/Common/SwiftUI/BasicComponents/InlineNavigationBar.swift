import SwiftUI

struct InlineNavigationBar<Title: View, Button: View>: View {
    
    private let title: Title
    private let rightButton: Button
    
    init(
        @ViewBuilder title: () -> Title,
        @ViewBuilder rightButton: () -> Button
    ) {
        self.title = title()
        self.rightButton = rightButton()
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(maxWidth: .infinity)
            
            title
                .frame(maxWidth: .infinity)
            
            rightView
                .frame(maxWidth: .infinity)
        }
        .frame(height: 48)
    }
    
    private var rightView: some View {
        HStack {
            Spacer()
            rightButton.padding(.horizontal, 16)
        }
    }
    
}

struct InlineNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        InlineNavigationBar(
            title: {
                AnytypeText("ad", style: .uxTitle1Semibold)
                    .foregroundColor(.Text.primary)
            },
            rightButton: {
                Button(action: {}) {
                    AnytypeText("ad", style: .uxBodyRegular)
                        .foregroundColor(.Text.primary)
                }
            }
        )
    }
}
