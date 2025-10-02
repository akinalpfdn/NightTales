//
//  FrameworkTest.swift
//  NightTales
//
//  Framework availability test
//

import Foundation
import FoundationModels
import Speech
import PhotosUI
import _PhotosUI_SwiftUI

// Test Foundation Models availability
func testFoundationModels() {
    // This will compile if FoundationModels framework is properly linked
    let _ = SystemLanguageModel.self
}

// Test Speech framework availability
func testSpeech() {
    // This will compile if Speech framework is properly linked
    let _ = SFSpeechRecognizer.self
}

// Test PhotosUI framework availability
func testPhotosUI() {
    // This will compile if PhotosUI framework is properly linked
    let _ = PhotosPickerItem.self
}
