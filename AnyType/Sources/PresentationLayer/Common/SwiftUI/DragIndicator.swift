import SwiftUI

struct DragIndicator: View {
    var body: some View {
        HStack {
            Spacer()
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.divider)
                .frame(width: 48, height: 5)
            Spacer()
        }
        .padding()
    }
}

struct DragIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DragIndicator()
    }
}
