//
//  ERP_PRO_iOS_AppApp.swift
//  ERP-PRO-iOS-App
//
//  Created by Dhairya Patel on 17/09/26.
//

import SwiftUI
import CoreData

@main
struct ERP_PRO_iOS_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
