import SwiftUI
import Services


struct PublishedSitesView: View {
    @StateObject private var model = PublishedSitesViewModel()
    @Environment(\.pageNavigation) private var pageNavigation
    
    var body: some View {
        VStack(spacing: 0) {
            DragIndicator()
            TitleView(title: Loc.mySites)
            content
        }
        .snackbar(toastBarData: $model.toastBarData)
        .safariSheet(url: $model.safariUrl)
        
        .task { await model.loadData() }
        .onAppear { model.pageNavigation = pageNavigation }
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
            Button {
                model.onOpenObjectTap(site)
            } label: {
                IconView(icon: site.details.objectIconImage)
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 0) {
                    Text(site.details.name)
                        .anytypeStyle(.uxTitle2Medium)
                        .lineLimit(1)
                    HStack(alignment: .center, spacing: 6) {
                        Text("\(model.formattedDate(site.date))")
                            .anytypeStyle(.caption1Regular)
                            .foregroundStyle(Color.Text.secondary)
                            .lineLimit(1)
                        
                        Circle()
                            .frame(width: 2, height: 2)
                            .foregroundStyle(Color.Text.secondary)
                        
                        Text("\(model.formattedSize(site.size))")
                            .anytypeStyle(.caption1Regular)
                            .foregroundStyle(Color.Text.secondary)
                            .lineLimit(1)
                    }
                }
                Spacer()
            }
            
            
            Menu {
                menuButtons(site)
            } label: {
                MoreIndicator()
                    .padding()
            }

        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private func menuButtons(_ site: PublishState) -> some View {
        Group {
            Button {
                model.onOpenObjectTap(site)
            } label: {
                Text(Loc.openObject)
                Spacer()
                Image(systemName: "arrow.down.left.and.arrow.up.right")
            }
            
            Button {
                model.onViewInBrowserTap(site)
            } label: {
                Text(Loc.viewInBrowser)
                Spacer()
                Image(systemName: "globe")
            }
            
            Button {
                model.onCopyLinkTap(site)
            } label: {
                Text(Loc.copyLink)
                Spacer()
                Image(systemName: "document.on.document")
            }
            
            Divider()
            
            AsyncButton(role: .destructive) {
                try await model.onUnpublishTap(site)
            } label: {
                Text(Loc.unpublish)
                Spacer()
                Image(systemName: "xmark")
            }
        }
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
