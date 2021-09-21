//
//  iCloudBackupConfigurator.swift
//  Anytype
//
//  Created by Denis Batvinkin on 20.09.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation


final class iCloudBackupConfigurator: AppConfiguratorProtocol {

    // https://developer.apple.com/documentation/foundation/optimizing_app_data_for_icloud_backup
    func configure() {
        let pathsLibAll = FileManager.default.urls(for: .allLibrariesDirectory, in: .userDomainMask)
        let pathsAppAll = FileManager.default.urls(for: .allApplicationsDirectory, in: .userDomainMask)
        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        (pathsLibAll + pathsAppAll + docDir + appSupportDir).forEach { url in
            var url = url
            try? url.setResourceValues(values)
        }
    }
}
