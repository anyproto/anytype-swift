import Foundation
import Combine
import SwiftUI
import os


extension ProfileView {
    struct AboutView: View {
        @ObservedObject var viewModel: ViewModel
        
        var view: some View {
            VStack {
                DragIndicator()
                AnytypeText("About application information", style: .title)
                    .padding(.top, 34).fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.center)
                AnytypeText("Library version \(self.viewModel.libraryVersion)", style: .body)
                    .padding(.top, 25)
                Spacer()
            }
            .padding([.leading, .trailing])
        }
        
        var body: some View {
            self.view.onAppear {
                self.viewModel.viewLoaded()
            }
        }
    }
}

extension ProfileView.AboutView {
    class ViewModel: ObservableObject {
        private var configurationService: ConfigurationServiceProtocol = MiddlewareConfigurationService()
        private var subscriptions: Set<AnyCancellable> = []
        @Published var libraryVersion: String = ""

        func viewLoaded() {
            self.configurationService.obtainLibraryVersion().reciveOnMain().sink(receiveCompletion: { (value) in
                switch value {
                case .finished: break
                case let .failure(error):
                    assertionFailure("Obtain library version error has occured: \(error)")
                }
            }, receiveValue: { [weak self] value in
                self?.libraryVersion = value.version
            }).store(in: &self.subscriptions)
        }
    }
}
