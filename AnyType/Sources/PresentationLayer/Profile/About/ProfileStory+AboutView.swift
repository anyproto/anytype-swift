import Foundation
import Combine
import SwiftUI
import os


extension ProfileView {
    struct AboutView: View {
        @ObservedObject var viewModel: ViewModel
        
        var view: some View {
            VStack {
                HStack {
                    Spacer()
                    Rectangle()
                        .cornerRadius(6)
                        .frame(width: 48, height: 5)
                        .foregroundColor(Color("DividerColor"))
                    Spacer()
                }
                .padding(.top, 6)
                Text("About application information")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 34).fixedSize(horizontal: false, vertical: true).multilineTextAlignment(.center)
                Text("Library version \(self.viewModel.libraryVersion)")
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.top, 25)
            }
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
            self.configurationService.obtainLibraryVersion().receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
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
