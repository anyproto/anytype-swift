import SwiftUI

struct SelectionIndicatorView: View {
    
    let model: Model
    
    var body: some View {
        switch model {
        case .notSelected:
            notSelectedView
        case let .selected(index):
            selectedView(index: index)
        }
    }
    
    private var notSelectedView: some View {
        Circle()
            .strokeBorder(Color.Control.inactive, lineWidth: 1.5)
            .frame(width: 24, height: 24)
    }
    
    private func selectedView(index: Int) -> some View {
        AnytypeText("\(index)", style: .uxTitle2Medium)
            .foregroundColor(.Text.white)
            .lineLimit(1)
            .frame(width:24, height: 24)
            .background(Color.Pure.sky)
            .clipShape(Circle())
    }
}

extension SelectionIndicatorView {
    
    enum Model {
        case notSelected
        case selected(index: Int)
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
