import SwiftUI

struct DragIndicator: View {
    var bottomPadding: CGFloat = 6
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.strokePrimary)
                    .frame(width: 48, height: 5)
                Spacer()
            }
            .frame(height: 22)
            
            Spacer.fixedHeight(bottomPadding)
        }
    }
}

struct DragIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DragIndicator()
    }
}
