//
//  FloatingActionButton.swift
//  NightTales
//
//  Floating action button with native iOS 26 Liquid Glass
//

import SwiftUI

struct FloatingActionButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "moon.stars.fill")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 60, height: 60)
        }
        .dreamGlass(.lucid, shape: .circle)
    }
}

#Preview {
    ZStack {
        LinearGradient(
            colors: [.black, .purple.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack {
            Spacer()
            HStack {
                Spacer()
                FloatingActionButton { }
                    .padding(24)
            }
        }
    }
}
