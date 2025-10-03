//
//  ErrorView.swift
//  NightTales
//
//  Error display with Liquid Glass design
//

import SwiftUI

struct ErrorView: View {
    let error: any AppError
    let onRetry: (() async -> Void)?
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Error Icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.red.opacity(0.3),
                                Color.red.opacity(0)
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 60
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.red)
            }

            // Error Details
            VStack(spacing: 12) {
                Text(error.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(error.message)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)

                if let suggestion = error.recoverySuggestion {
                    Text(suggestion)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                }
            }
            .padding(.horizontal, 24)

            // Actions
            VStack(spacing: 12) {
                if error.isRetryable, let onRetry = onRetry {
                    Button {
                        Task {
                            await onRetry()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    }
                    .dreamGlass(.mystic, shape: AnyShape(RoundedRectangle(cornerRadius: 16)))
                }

                Button {
                    onDismiss()
                } label: {
                    Text(error.isRetryable ? "Dismiss" : "OK")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .glassEffect(.clear, in: .rect(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
        }
        .padding(32)
        .frame(maxWidth: 400)
        .dreamGlass(.nightmare, shape: AnyShape(RoundedRectangle(cornerRadius: 24)))
        .padding(24)
    }
}

// MARK: - Error Alert Modifier

extension View {
    func errorAlert(
        error: Binding<(any AppError)?>,
        isPresented: Binding<Bool>,
        onRetry: (() async -> Void)? = nil
    ) -> some View {
        self.overlay {
            if isPresented.wrappedValue, let currentError = error.wrappedValue {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isPresented.wrappedValue = false
                        }

                    ErrorView(
                        error: currentError,
                        onRetry: onRetry,
                        onDismiss: {
                            isPresented.wrappedValue = false
                            error.wrappedValue = nil
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                .animation(.spring(response: 0.4), value: isPresented.wrappedValue)
            }
        }
    }
}

#Preview("AI Error - Retryable") {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        ErrorView(
            error: AIError.interpretationFailed(NSError(domain: "test", code: 1)),
            onRetry: {
                print("Retry tapped")
            },
            onDismiss: {
                print("Dismiss tapped")
            }
        )
    }
}

#Preview("Voice Error - Not Retryable") {
    ZStack {
        DreamBackground(mood: .neutral)
            .ignoresSafeArea()

        ErrorView(
            error: VoiceError.microphonePermissionDenied,
            onRetry: nil,
            onDismiss: {
                print("Dismiss tapped")
            }
        )
    }
}
