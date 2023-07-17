import SwiftUI

struct ButtonLoadingView: View {
    
    private enum Constants {
        static let animationDutation: CGFloat = 0.1
        static let dotsCount: Int = 3
    }
    
    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    @State private var fillCircleIndex = 0
    
    var body: some View {
        HStack(alignment: .center) {
            ForEach(0..<Constants.dotsCount, id: \.self) {
                circle(index: $0)
            }
        }
        .onReceive(timer) { _ in
            fillCircleIndex = (fillCircleIndex + 1) % Constants.dotsCount
        }
        .frame(idealWidth: 50, idealHeight: 6)
    }
    
    @ViewBuilder
    private func circle(index: Int) -> some View {
        let fill = index == fillCircleIndex
        ZStack {
            Circle()
                .strokeBorder(.foreground)
            if fill {
                Circle()
                    .fill(.foreground)
            }
        }
        .animation(.linear(duration: Constants.animationDutation), value: fill)
    }
}

struct ButtonLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonLoadingView()
            .frame(width: 60, height: 60)
    }
}
