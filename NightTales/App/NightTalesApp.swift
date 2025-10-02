//
//  NightTalesApp.swift
//  NightTales
//
//  Created by Akinalp Fidan on 2.10.2025.
//

import SwiftUI
import SwiftData
import FoundationModels
import Speech
import PhotosUI

@main
struct NightTalesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Dream.self,
            DreamSymbol.self,
            DreamPattern.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
