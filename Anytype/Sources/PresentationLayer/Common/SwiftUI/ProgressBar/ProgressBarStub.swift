import SwiftUI

struct ProgressBarStub: View {
    var body: some View {
        ZStack(alignment: .center) {
            Capsule()
                .foregroundColor(.strokePrimary)
            Capsule()
                .foregroundColor(.TextNew.primary)
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
