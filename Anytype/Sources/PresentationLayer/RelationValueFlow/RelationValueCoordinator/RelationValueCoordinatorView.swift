import Foundation
import SwiftUI

struct RelationValueCoordinatorView: View {
    
    @StateObject var model: RelationValueCoordinatorViewModel
    
    var body: some View {
        model.relationModule()
            .if(model.mediumDetent) {
                $0.mediumPresentationDetents()
            }
    }
}
