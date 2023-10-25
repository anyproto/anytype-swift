import SwiftUI

struct ShareView: View {
    @StateObject var viewModel: ShareViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 8) {
                    viewModel.contentViewModel.showingView
                }
            }.padding(.horizontal, 16)
                .background(UIColor.systemGroupedBackground.suColor)
                .navigationTitle(Loc.Sharing.Navigation.title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading:
                    Button(Loc.Sharing.Navigation.LeftButton.title, role: .cancel) {
                        viewModel.tapClose()
                    },
                trailing:
                    Button(Loc.Sharing.Navigation.RightButton.title, role: .destructive) {
                        viewModel.tapSave()
                    }.disabled(!viewModel.isSaveButtonAvailable)
            )
        }
    }
}

struct SectionTitle: View {
    let title: String
    
    var body: some View {
        HStack {
            Spacer.fixedWidth(16)
            AnytypeText(title, style: .caption1Medium, color: UIColor.secondaryLabel.suColor)
            Spacer()
        }
    }
}

struct ShareView_Previews: PreviewProvider {    
    static var previews: some View {
        ShareView(
            viewModel: .init(
                contentViewModel: URLShareViewModel(
                    url: URL(string: "http://anytype.io")!,
                    onDocumentSelection: { _ in }, 
                    onSpaceSelection: { _ in }
                ),
                interactor: ServiceLocator().sharedContentInteractor,
                contentManager: ServiceLocator().sharedContentManager
            )
        )
    }
}
