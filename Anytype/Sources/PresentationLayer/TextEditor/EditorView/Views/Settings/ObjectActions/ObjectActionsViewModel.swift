//
//  ObjectActionsViewModel.swift
//  Anytype
//
//  Created by Denis Batvinkin on 24.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Combine


final class ObjectActionsViewModel: ObservableObject {

    var objectActions: [ObjectAction] {
        ObjectAction.allCases
    }

    func archiveObject() {
    }

    func favoriteObject() {
    }

    func moveTo() {
    }

    func template() {
    }

    func search() {
    }

}
