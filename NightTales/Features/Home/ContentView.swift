//
//  ContentView.swift
//  NightTales
//
//  Created by Akinalp Fidan on 2.10.2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dreams: [Dream]

    var body: some View {
        NavigationStack {
            VStack {
                Text("NightTales")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Dream Interpreter")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("\(dreams.count) dreams recorded")
                    .font(.headline)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Dream.self, inMemory: true)
}
