//
//  SymbolLibraryView.swift
//  NightTales
//
//  Symbol library with search and category filter
//

import SwiftUI
import SwiftData

struct SymbolLibraryView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    @State private var selectedCategory: String?
    @State private var symbols: [DreamSymbol] = []

    private let symbolService: SymbolService
    private let categories = ["All", "People", "Animals", "Nature", "Objects", "Emotions", "Places"]

    init(modelContext: ModelContext) {
        self.symbolService = SymbolService(modelContext: modelContext)
    }

    var filteredSymbols: [DreamSymbol] {
        var result = symbols

        // Filter by category
        if let category = selectedCategory, category != "All" {
            result = result.filter { $0.category.localizedCaseInsensitiveContains(category) }
        }

        // Filter by search
        if !searchText.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }

        return result
    }

    var body: some View {
        ZStack {
            // Background
            DreamBackground(mood: .pleasant)
                .ignoresSafeArea()

            if symbols.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    // Header
                    header

                    // Search Bar
                    searchBar
                        .padding(.horizontal)
                        .padding(.top, 8)

                    // Category Filter
                    categoryFilter
                        .padding(.vertical, 12)

                    // Symbol Grid
                    symbolGrid
                }
            }
        }
        .onAppear {
            loadSymbols()
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 8) {
            Text("Symbol Library")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text("\(symbols.count) symbols discovered")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.6))

            TextField("Search symbols...", text: $searchText)
                .foregroundStyle(.white)
                .tint(Color.dreamPurple)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .dreamGlass(.calm, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    categoryPill(category)
                }
            }
            .padding(.horizontal)
        }
    }

    private func categoryPill(_ category: String) -> some View {
        let isSelected = selectedCategory == category || (selectedCategory == nil && category == "All")

        return Button {
            withAnimation(.spring(response: 0.3)) {
                selectedCategory = category == "All" ? nil : category
            }
        } label: {
            Text(category)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .glassEffect(
            isSelected ? .regular.tint(Color.dreamPurple.opacity(0.6)).interactive() : .clear,
            in: .capsule
        )
    }

    // MARK: - Symbol Grid
    private var symbolGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredSymbols) { symbol in
                    SymbolCardView(symbol: symbol)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        EmptyStateView(
            title: "No Symbols Yet",
            message: "Symbols will appear here as you record and interpret your dreams",
            actionTitle: nil,
            action: nil
        )
    }

    // MARK: - Load Symbols
    private func loadSymbols() {
        do {
            symbols = try symbolService.fetchAllSymbols(sortBy: .frequencyDescending)
        } catch {
            print("Failed to load symbols: \(error)")
        }
    }
}

#Preview {
    SymbolLibraryView(
        modelContext: ModelContext(
            try! ModelContainer(for: DreamSymbol.self, configurations: .init(isStoredInMemoryOnly: true))
        )
    )
}
