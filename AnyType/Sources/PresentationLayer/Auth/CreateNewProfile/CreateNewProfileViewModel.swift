//
//  CreateNewProfileViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 09.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI


class CreateNewProfileViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var image: UIImage? = nil
    @Published var disableButton: Bool = true
    
    private var waitingViewOnCreatAccountModel: WaitingViewOnCreatAccountModel
    
    init() {
        waitingViewOnCreatAccountModel = WaitingViewOnCreatAccountModel(userName: "", image: nil)
    }
    
    func showSetupWallet() -> some View {
        waitingViewOnCreatAccountModel.userName = userName
        waitingViewOnCreatAccountModel.image = image
        
        return WaitingViewOnCreatAccount(viewModel: waitingViewOnCreatAccountModel)
    }
}
