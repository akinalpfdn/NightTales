//
//  View+Keyboard.swift
//  NightTales
//
//  Keyboard dismiss helpers
//

import SwiftUI

extension View {
    /// Dismiss keyboard when tapping outside
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            hideKeyboard()
        }
    }

    /// Hide keyboard programmatically
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
