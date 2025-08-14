import SwiftUI
import Services


struct PublishedSitesView: View {
    @StateObject private var model: PublishedSitesViewModel
    
    init() {
        _model = StateObject(wrappedValue: PublishedSitesViewModel())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.mySites)
            content
        }
        .task { await model.loadData() }
    }
    
    var content: some View {
        Group {
            if let error = model.error {
                errorView(error)
            } else {
                if let sites = model.sites {
                    if sites.isEmpty {
                        emptyView
                    } else {
                        sitesList(sites)
                    }
                } else {
                    Spacer()
                }
            }
        }
    }
    
    private func sitesList(_ sites: [PublishState]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(sites, id: \.objectId) {
                    siteRow($0)
                        .newDivider()
                }
            }
        }
    }
    
    private func siteRow(_ site: PublishState) -> some View {
        HStack(spacing: 12) {
            IconView(icon: site.details.objectIconImage)
                .frame(width: 48, height: 48)
            Text(site.details.name)
                .anytypeStyle(.uxTitle2Medium)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var emptyView: some View {
        EmptyStateView(
            title: Loc.EmptyView.Default.title,
            subtitle: Loc.EmptyView.Publishing.subtitle,
            style: .withImage
        )
    }

    private func errorView(_ error: String) -> some View {
        EmptyStateView(
            title: Loc.Error.Common.title,
            subtitle: error,
            style: .error,
            buttonData: EmptyStateView.ButtonData(
                title: Loc.tryAgain,
                action: { await model.loadData() }
            )
        )
    }
}

#Preview {
    PublishedSitesView()
}
