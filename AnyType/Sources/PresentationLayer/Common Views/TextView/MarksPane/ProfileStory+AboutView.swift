//
//  ProfileStory+AboutView.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 28.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import os

private extension Logging.Categories {
    static let profileStoryAboutView: Self = "ProfileStory.AboutView"
}

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
                    .padding(.top, 34)
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
                    let logger = Logging.createLogger(category: .profileStoryAboutView)
                    os_log(.debug, log: logger, "Obtain library version error has occured: %@", String(describing: error))
                }
            }, receiveValue: { [weak self] value in
                self?.libraryVersion = value.version
            }).store(in: &self.subscriptions)
        }
    }
}
