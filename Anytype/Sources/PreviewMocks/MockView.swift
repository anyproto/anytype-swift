import Foundation
import Factory
import SwiftUI
import AnytypeCore

/// Example:
/// MockView  {
///    SomeModuleView()
/// }
///
/// or for setup custom state in mocks:
///
/// MockView {
///    WorkspacesStorageMock.shared.workspaces = [...]
/// } content: {
///    SomeModuleView()
/// }
///
struct MockView<Content: View>: View {
    
    private let content: Content
    
    init(сonfigure: (() -> Void)? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        setupPreviewMocks()
        сonfigure?()
    }
    
    var body: some View {
        content
            .onAppear {
                if !AppContext.isPreview {
                    anytypeAssertionFailure("App uses MockView not for preview")
                }
            }
    }
    
    private func setupPreviewMocks() {
        Container.shared.workspaceStorage.onPreview {
            WorkspacesStorageMock.shared
        }
        Container.shared.singleObjectSubscriptionService.onPreview {
            SingleObjectSubscriptionServiceMock.shared
        }
        Container.shared.membershipStatusStorage.onPreview {
            MembershipStatusStorageMock.shared
        }
        Container.shared.fileLimitsStorage.onPreview {
            FileLimitsStorageMock.shared
        }
        Container.shared.syncStatusStorage.onPreview {
            SyncStatusStorageMock.shared
        }
        Container.shared.participantSpacesStorage.onPreview {
            ParticipantSpacesStorageMock.shared
        }
    }
}
