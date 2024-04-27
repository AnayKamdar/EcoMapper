//
//  EcoMapperApp.swift
//  EcoMapper
//
//  Created by Anay Kamdar on 3/18/24.
//

import SwiftUI
@main
struct EcoMapperApp: App {
    @StateObject private var viewModel = EnvironmentalDataViewModel()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
