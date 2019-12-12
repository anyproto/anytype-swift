//
//  SelectProfileViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI
import Combine


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
    @Environment(\.authService) private var authService
    @Environment(\.localRepoService) private var localRepoService
    @Environment(\.ipfsFilesServie) private var ipfsFileService
    
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
        DispatchQueue.global().async {
            self.handleAccountShowEvent()
            
            self.authService.accountRecover { [weak self] result in
                if case .failure(let .recoverWalletError(error)) = result {
                    self?.error = error
                    return
                }
            }
        }
    }
    
    func selectProfile(id: String) {
        self.authService.selectAccount(id: id, path: localRepoService.middlewareRepoPath) { result in
            switch result {
            case .success:
                self.showHomeView()
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
        .map { $0.messages }
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
            for event in events {
                let account = event.accountShow

                let profileViewModel = ProfileNameViewModel(id: account.account.id)
                profileViewModel.name = account.account.name
                
                switch account.account.avatar.avatar {
                case .color(let hexColor):
                    profileViewModel.color = UIColor(hexString: hexColor)
                case .image(let imageModel):
                    print("img crashed")
                    // TODO: uncomment when fetching img will be fixed
                    self?.downloadAvatarImage(imageModel: imageModel, profileViewModel: profileViewModel)
                default: break
                }
                
                self?.profilesViewModels.append(profileViewModel)
            }
        }
    }
    
    private func downloadAvatarImage(imageModel: Anytype_Model_Image, profileViewModel: ProfileNameViewModel) {
        var imageSize: Anytype_Model_Image.Size = .large
        
        if imageModel.sizes.contains(.thumb) {
            imageSize = .thumb
        } else if imageModel.sizes.contains(.small) {
            imageSize = .small
        }
        
        let request = IpfsFilesModel.Image.Download.Request(id: imageModel.id, size: imageSize)
        
        avatarCancellable = ipfsFileService.fetchImage(requestModel: request)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            }) { data in
                profileViewModel.image = UIImage(data: data)
        }
    }
    
    // MARK: - Coordinator
    
    func showCreateProfileView() -> some View {
        return CreateNewProfileView(viewModel: CreateNewProfileViewModel())
    }
    
    func showHomeView() {
        applicationCoordinator?.startNewRootView(content: HomeViewContainer())
    }
}
