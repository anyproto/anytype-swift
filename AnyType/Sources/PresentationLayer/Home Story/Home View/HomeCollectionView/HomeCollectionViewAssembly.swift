import SwiftUI

class HomeCollectionViewAssembly {
    
    // MARK: - Public methods
    
    // TODO: workaround - we need inject viewmodel and documentsCell from outer env due to fucking swiftui doesn't update
    // UIViewRepresentable views when ObservedObject changed
    func createHomeCollectionView(
        showDocument: Binding<Bool>,
        selectedDocumentId: Binding<String>,
        containerSize: CGSize,
        cellsModels: Binding<[HomeCollectionViewCellType]>
    ) -> some View {
        let homeViewContainer = HomeCollectionView(
            showDocument: showDocument, selectedDocumentId: selectedDocumentId, documentsCell: cellsModels, containerSize: containerSize
        )
        
        return homeViewContainer
    }
}
