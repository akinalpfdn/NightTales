//
//  ShareManager.swift
//  NightTales
//
//  Share dream as text or image
//

import SwiftUI
import UIKit

@MainActor
class ShareManager {
    static let shared = ShareManager()

    private init() {}

    // MARK: - Share as Text

    func shareDreamAsText(dream: Dream, includeInterpretation: Bool = false) -> String {
        var text = """
        🌙 Dream Journal Entry

        Date: \(formatDate(dream.date))
        Mood: \(dream.mood.rawValue)
        \(dream.isLucidDream ? "✨ Lucid Dream" : "")

        """

        if !dream.title.isEmpty {
            text += "Title: \(dream.title)\n\n"
        }

        text += dream.content

        if !dream.symbols.isEmpty {
            text += "\n\n🔮 Symbols: \(dream.symbols.joined(separator: ", "))"
        }

        if includeInterpretation, let interpretation = dream.aiInterpretation {
            text += "\n\n💭 Interpretation:\n\(interpretation)"
        }

        text += "\n\n—\nShared from NightTales"

        return text
    }

    // MARK: - Share as Image

    func shareDreamAsImage(dream: Dream, includeInterpretation: Bool = false) -> UIImage? {
        let view = DreamShareCardView(dream: dream, includeInterpretation: includeInterpretation)

        let controller = UIHostingController(rootView: view)
        let targetSize = CGSize(width: 375, height: 600)
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }

    // MARK: - Present Share Sheet

    func presentShareSheet(items: [Any], from viewController: UIViewController? = nil) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // For iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                       y: rootViewController.view.bounds.midY,
                                       width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        let presenter = viewController ?? rootViewController
        presenter.present(activityViewController, animated: true)
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Dream Share Card View

struct DreamShareCardView: View {
    let dream: Dream
    let includeInterpretation: Bool

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#1a1a2e"),
                    Color(hex: "#16213e"),
                    Color(hex: "#0f3460")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .font(.title2)
                            .foregroundStyle(Color.dreamPurple)

                        Text("NightTales")
                            .font(.title3.bold())
                            .foregroundStyle(.white)
                    }

                    Text(formatDate(dream.date))
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }

                // Mood & Lucid Badge
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: dream.mood.icon)
                            .foregroundStyle(dream.mood.color)
                        Text(dream.mood.rawValue.capitalized)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)

                    if dream.isLucidDream {
                        Text("✨ Lucid")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.dreamPurple.opacity(0.3))
                            .cornerRadius(12)
                    }
                }

                // Title
                if !dream.title.isEmpty {
                    Text(dream.title)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }

                // Content
                ScrollView {
                    Text(dream.content)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.leading)
                        .lineLimit(10)
                }
                .frame(maxHeight: 200)

                // Symbols
                if !dream.symbols.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Symbols")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))

                        FlowLayout(spacing: 8) {
                            ForEach(dream.symbols.prefix(6), id: \.self) { symbol in
                                Text(symbol)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Interpretation
                if includeInterpretation, let interpretation = dream.aiInterpretation {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Interpretation")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))

                        Text(interpretation)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                            .lineLimit(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .padding(24)
        }
        .frame(width: 375, height: 600)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - SwiftUI Share Extension

extension View {
    func shareSheet(isPresented: Binding<Bool>, items: [Any]) -> some View {
        self.sheet(isPresented: isPresented) {
            ShareSheet(items: items)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
