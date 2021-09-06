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
        HStack {
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
            rightButton.padding(.horizontal)
        }
    }
    
}

struct InlineNavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        InlineNavigationBar(
            title: {
                AnytypeText("ad", style: .uxTitle1Semibold)
            },
            rightButton: {
                Button(action: {}) {
                    AnytypeText("ad", style: .uxBodyRegular)
                }
            }
        )
    }
}
