import SwiftUI

struct HomeBackgroundBlurView: View {
    var body: some View {
        VisualEffectBlur(blurStyle: .systemThinMaterialLight, vibrancyStyle: .fill) {
            EmptyView()
        }
    }
}

struct HomeBackgroundBlurView_Previews: PreviewProvider {
    static var previews: some View {
        HomeBackgroundBlurView()
    }
}
