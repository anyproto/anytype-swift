import Foundation
import SwiftUI

struct StatusSearchRow: NewSearchRowProtocol {
    
    let id = UUID()
    let viewModel: StatusSearchRowViewModel
    
    func view(onTap: @escaping () -> ()) -> AnyView {
        AnyView(
            StatusSearchRowView(viewModel: viewModel, onTap: onTap)
        )
    }
    
}
