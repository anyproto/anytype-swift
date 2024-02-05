import SwiftUI

struct SelectionIndicatorView: View {
    
    let model: Model
    
    var body: some View {
        switch model {
        case .notSelected:
            notSelectedView
        case let .selected(index, color):
            selectedView(index: index, color: color)
        }
    }
    
    private var notSelectedView: some View {
        Circle()
            .strokeBorder(Color.Button.inactive, lineWidth: 1.5)
            .frame(width: 24, height: 24)
    }
    
    private func selectedView(index: Int, color: Color) -> some View {
        AnytypeText("\(index)", style: .uxTitle2Medium, color: .Text.white)
            .lineLimit(1)
            .frame(width:24, height: 24)
            .background(color)
            .clipShape(Circle())
    }
}

extension SelectionIndicatorView {
    
    enum Model {
        case notSelected
        case selected(index: Int, color: Color = Color.Button.button)
    }
}

struct SelectionIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            SelectionIndicatorView(model: .selected(index: 3))
            SelectionIndicatorView(model: .notSelected)
        }
        
    }
}
