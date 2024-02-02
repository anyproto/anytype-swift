import SwiftUI

struct ProgressBarStub: View {
    var body: some View {
        ZStack(alignment: .center) {
            Capsule()
                .foregroundColor(.Shape.primary)
            Capsule()
                .foregroundColor(.Text.primary)
                .clipShape(Capsule())
        }
        .frame(height: 6)
    }
}

struct ProgressBarStub_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarStub().padding()
    }
}
