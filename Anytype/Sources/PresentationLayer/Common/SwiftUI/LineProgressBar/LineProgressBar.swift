import SwiftUI

struct LineProgressBar: View {
    
    @Environment(\.redactionReasons) var redactionReasons
    
    let percent: CGFloat
    let configuration: LineProgressBarConfiguration
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            Group {
                if redactionReasons.contains(.placeholder) {
                    Rectangle().foregroundColor(configuration.foregroundColor)
                } else {
                    ZStack(alignment: .leading) {
                        Rectangle().foregroundColor(configuration.foregroundColor)
                        Rectangle().foregroundColor(configuration.innerForegroundColor)
                            .ifLet(configuration.innerCornerRadius, transform: { view, radius in
                                view.cornerRadius(radius, style: .continuous)
                            })
                            .frame(width: frame.width * percent)
                    }
                }
            }
            .cornerRadius(configuration.cornerRadius, style: .continuous)
        }
        .frame(height: configuration.height)
    }
}

struct LineProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        LineProgressBar(percent: 0.2, configuration: LineProgressBarConfiguration.fileStorage)
            .frame(width: 300)
    }
}
