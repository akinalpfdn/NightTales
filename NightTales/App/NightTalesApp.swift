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
    @State private var showLaunchScreen = true

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
            ZStack {
                ContentView()
                    .modelContainer(sharedModelContainer)

                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                // Hide launch screen after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation(.easeOut(duration: 0.5)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
}
