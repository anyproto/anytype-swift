import SwiftUI

struct DragIndicator: View {
    var bottomPadding: CGFloat = 6
    
    var body: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.divider)
                .frame(width: 48, height: 5)
            Spacer()
        }
        .frame(height: 22)
        .padding(.bottom, bottomPadding)
    }
}

struct DragIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DragIndicator()
    }
}
