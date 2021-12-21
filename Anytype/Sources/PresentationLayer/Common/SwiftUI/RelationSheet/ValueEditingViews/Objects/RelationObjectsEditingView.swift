import SwiftUI

struct RelationObjectsEditingView: View {
    
    @ObservedObject var viewModel: RelationObjectsEditingViewModel
    
    var body: some View {
        content
            .modifier(
                RelationSheetModifier(isPresented: $viewModel.isPresented, title: nil, dismissCallback: viewModel.dismissHandler)
            )
    }
    
    private var content: some View {
        Group {
            if viewModel.selectedObjects.isEmpty {
                emptyView
            } else {
                NavigationView {
                    objectsList
                        .navigationBarTitle(viewModel.relationName, displayMode: .inline)
                }
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 0) {
            AnytypeText("Empty".localized, style: .uxCalloutRegular, color: .textTertiary)
                .padding(.vertical, 13)
            Spacer.fixedHeight(20)
        }
    }
    
    private var objectsList: some View {
        List {
            ForEach(viewModel.selectedObjects) { RelationObjectsRowView(object: $0) }
        }
        .padding(.bottom, 20)
        .listStyle(.plain)
    }
}

//struct RelationObjectsEditingView_Previews: PreviewProvider {
//    static var previews: some View {
//        RelationObjectsEditingView()
//    }
//}
