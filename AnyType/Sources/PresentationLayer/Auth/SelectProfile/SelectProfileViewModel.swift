//
//  SelectProfileViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine
import ProtobufMessages

class ProfileNameViewModel: ObservableObject, Identifiable {
    var id: String
    @Published var image: UIImage? = nil
    @Published var color: UIColor?
    @Published var name: String = ""
    @Published var peers: String?
    
    init(id: String) {
        self.id = id
    }
}


class SelectProfileViewModel: ObservableObject {
    let isMultipleAccountsEnabled = false // Not supported yet
    
    private let localRepoService  = ServiceLocator.shared.localRepoService()
    private let authService  = ServiceLocator.shared.authService()

    @Environment(\.fileService) private var fileService
    
    private var cancellable: AnyCancellable?
    private var avatarCancellable: AnyCancellable?
    
    @Published var profilesViewModels = [ProfileNameViewModel]()
    @Published var error: String? {
        didSet {
            showError = false
            
            if error != nil {
                showError = true
            }
        }
    }
    @Published var showError: Bool = false
    
    func accountRecover() {
        DispatchQueue.global().async { [weak self] in
            self?.handleAccountShowEvent()
            self?.authService.accountRecover { result in
                if case let .failure(.recoverAccountError(error)) = result {
                    self?.error = error
                }
            }
        }
    }
    
    func selectProfile(id: String) {
        self.authService.selectAccount(id: id, path: localRepoService.middlewareRepoPath) { result in
            switch result {
            case .success:
                self.showOldHomeView()
            case .failure(let error):
                self.error = error.localizedDescription
            }
        }
    }
    
    // MARK: private func
    
    private func handleAccountShowEvent() {
        cancellable = NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
            .compactMap { notification in
                return notification.object as? Anytype_Event
        }
        .map(\.messages)
        .map {
            $0.filter { message in
                guard let value = message.value else { return false }
                
                if case Anytype_Event.Message.OneOf_Value.accountShow = value {
                    return true
                }
                return false
            }
        }
        .receive(on: RunLoop.main)
        .sink { [weak self] events in
            guard let self = self else {
                return
            }
            
            for event in events {
                let account = event.accountShow.account
                
                if self.isMultipleAccountsEnabled {
                    let profileViewModel = self.profileViewModelFromAccount(account)
                    self.profilesViewModels.append(profileViewModel)
                } else {
                    self.selectProfile(id: account.id)
                }
            }
        }
    }
    
    private func profileViewModelFromAccount(_ account: Anytype_Model_Account) -> ProfileNameViewModel {
        let profileViewModel = ProfileNameViewModel(id: account.id)
        profileViewModel.name = account.name
        
        switch account.avatar.avatar {
        case .color(let hexColor):
            profileViewModel.color = UIColor(hexString: hexColor)
        case .image(let file):
            let defaultWidth: CGFloat = 500
            let imageSize = Int32(defaultWidth * UIScreen.main.scale) // we also need device aspect ratio and etc.
            // so, it is better here to subscribe or take event from UIWindow and get its data.
            self.downloadAvatarImage(imageSize: imageSize, hash: file.hash, profileViewModel: profileViewModel)
        default: break
        }
        
        return profileViewModel
    }
    
    private func downloadAvatarImage(imageSize: Int32, hash: String, profileViewModel: ProfileNameViewModel) {
        _ = self.fileService.fetchImageAsBlob.action(hash: hash, wantWidth: imageSize).receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    self?.error = error.localizedDescription
                }
            }) { response in
                profileViewModel.image = UIImage(data: response.blob)
        }
    }
    
    // MARK: - Coordinator
    
    func showCreateProfileView() -> some View {
        return CreateNewProfileView(viewModel: CreateNewProfileViewModel())
    }
    
    func showOldHomeView() {
        let homeAssembly = OldHomeViewAssembly()
        windowHolder?.startNewRootView(homeAssembly.createOldHomeView())
    }
}
