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
///    SpaceViewStorageMock.shared.workspaces = [...]
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
        Container.shared.spaceViewStorage.register {
            SpaceViewStorageMock.shared
        }
        Container.shared.singleObjectSubscriptionService.register {
            SingleObjectSubscriptionServiceMock.shared
        }
        Container.shared.membershipStatusStorage.register {
            MembershipStatusStorageMock.shared
        }
        Container.shared.fileLimitsStorage.register {
            FileLimitsStorageMock.shared
        }
        Container.shared.syncStatusStorage.register {
            SyncStatusStorageMock.shared
        }
        Container.shared.participantSpaceStorage.register {
            ParticipantSpaceStorageMock.shared
        }
        Container.shared.searchService.register {
            SearchServiceMock.shared
        }
    }
}
