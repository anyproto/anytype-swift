//
//  CustomEnvironments.swift
//  AnyType
//
//  Created by Denis Batvinkin on 11.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import SwiftUI


struct LocalRepoServiceKey: EnvironmentKey {
    static let defaultValue: LocalRepoService = .init()
}

extension EnvironmentValues {
    var localRepoService: LocalRepoService {
        get {
            self[LocalRepoServiceKey.self]
        }
        set {
            self[LocalRepoServiceKey.self] = newValue
        }
    }
}


struct AuthServiceKey: EnvironmentKey {
    static let defaultValue: AuthService = .init()
}

extension EnvironmentValues {
    var authService: AuthService {
        get {
            self[AuthServiceKey.self]
        }
        set {
            self[AuthServiceKey.self] = newValue
        }
    }
}

struct FileServiceKey: EnvironmentKey {
    static let defaultValue: BlockActionsServiceFile = .init()
}

extension EnvironmentValues {
    var fileService: BlockActionsServiceFile {
        get {
            self[FileServiceKey.self]
        }
        set {
            self[FileServiceKey.self] = newValue
        }
    }
}

struct ShowViewFramesKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var showViewFrames: Bool {
        get {
            self[ShowViewFramesKey.self]
        }
        set {
            self[ShowViewFramesKey.self] = newValue
        }
    }
}


struct AddedScrollViewOffsetKey: EnvironmentKey {
    static let defaultValue: CGPoint = .zero
}

extension EnvironmentValues {
    var addedScrollViewOffset: CGPoint {
        get {
            self[AddedScrollViewOffsetKey.self]
        }
        set {
            self[AddedScrollViewOffsetKey.self] = newValue
        }
    }
}


struct TimingTimerKey: EnvironmentKey {
    static let defaultValue: TimingTimer = TimingTimer()
}

extension EnvironmentValues {
    var timingTimer: TimingTimer {
        get {
            self[TimingTimerKey.self]
        }
        set {
            self[TimingTimerKey.self] = newValue
        }
    }
}

struct DeveloperOptionsKey: EnvironmentKey {
    static let defaultValue: DeveloperOptions.Service = .init()
}

extension EnvironmentValues {
    var developerOptions: DeveloperOptions.Service {
        get {
            self[DeveloperOptionsKey.self]
        }
        set {
            self[DeveloperOptionsKey.self] = newValue
        }
    }
}

struct KeychainStoreServiceKey: EnvironmentKey {
    static let defaultValue: KeychainStoreService = .init()
}

extension EnvironmentValues {
    var keychainStoreService: KeychainStoreService {
        get {
            self[KeychainStoreServiceKey.self]
        }
        set {
            self[KeychainStoreServiceKey.self] = newValue
        }
    }
}
