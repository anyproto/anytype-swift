import Foundation
import SwiftUI

struct MultiSelectRelationListCoordinatorView: View {
    
    @StateObject var model: MultiSelectRelationListCoordinatorViewModel
    
    var body: some View {
        model.selectRelationListModule()
            .sheet(item: $model.relationData) { data in
                model.selectRelationCreate(data: data)
            }
            .anytypeSheet(item: $model.deletionAlertData) { data in
                model.deletionAlertView(data: data)
            }
    }
}
