//
//  ContentView.swift
//  NightTales
//
//  Main tab navigation
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        if hasCompletedOnboarding {
            mainTabView
        } else {
            OnboardingView()
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView(viewModel: HomeViewModel(modelContext: modelContext))
                .tag(0)
                .tabItem {
                    Label("Dreams", systemImage: "moon.stars.fill")
                }

            // Insights Tab
            InsightsView(viewModel: InsightsViewModel(modelContext: modelContext))
                .tag(1)
                .tabItem {
                    Label("Insights", systemImage: "chart.pie.fill")
                }

            // Symbols Tab
            SymbolLibraryView(modelContext: modelContext)
                .tag(2)
                .tabItem {
                    Label("Symbols", systemImage: "book.closed.fill")
                }

            // Settings Tab
            SettingsView(viewModel: SettingsViewModel(modelContext: modelContext))
                .tag(3)
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(Color.dreamPurple)
    }
}

// MARK: - Placeholder View
struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        ZStack {
            DreamBackground(mood: .pleasant)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 80))
                    .foregroundStyle(Color.dreamPurple)

                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Text("Coming soon...")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Dream.self, inMemory: true)
}
