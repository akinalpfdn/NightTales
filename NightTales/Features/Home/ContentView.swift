//
//  ContentView.swift
//  NightTales
//
//  Main app view - shows HomeView on launch
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HomeView(viewModel: HomeViewModel(modelContext: modelContext))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Dream.self, inMemory: true)
}
