//
//  ERP_PRO_iOS_AppApp.swift
//  ERP-PRO-iOS-App
//

import SwiftUI
import CoreData

@main
struct ERP_PRO_iOS_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
