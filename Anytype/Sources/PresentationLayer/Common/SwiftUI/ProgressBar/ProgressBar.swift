import SwiftUI

struct ProgressBar: View {
    var showAnimation: Bool

    var body: some View {
        Group {
            if showAnimation {
                ProgressBarWithAnimation()
            } else {
                ProgressBarStub()
            }
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBar(showAnimation: true).padding()
    }
}
