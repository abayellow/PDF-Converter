//
//  PDF_ConverterApp.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

@main
struct PDF_ConverterApp: App {
    var body: some Scene {
        WindowGroup {
            FilesContentView()
                .preferredColorScheme(.light)
        }
    }
}
