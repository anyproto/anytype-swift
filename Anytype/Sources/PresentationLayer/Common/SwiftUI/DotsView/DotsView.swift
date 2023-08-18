import SwiftUI

struct DotsView: View {
    
    private enum Constants {
        static let countDots = 3
    }
    
    private let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    @State private var activeDot: Int = 0
    
    var body: some View {
        GeometryReader { reader in
            // Fix Circle size.
            // With strokeBorder API, clrcle calculate incorrect size for width.
            // Width and height should be equal, but width is bigger.
            // At the same time normal behavior for stroke API 😬.
            let side = min(reader.size.width, reader.size.height)
            HStack {
                ForEach(0..<3) { index in
                    DotView(filled: activeDot == index)
                        .frame(width: side, height: side)
                    if index != Constants.countDots - 1 {
                        Spacer()
                    }
                }
            }
            
        }
        .onReceive(timer) { _ in
            activeDot = (activeDot + 1) % Constants.countDots
        }
        .frame(idealWidth: 50, idealHeight: 6)
    }
}

struct DotsView_Previews: PreviewProvider {
    static var previews: some View {
        DotsView()
    }
}
