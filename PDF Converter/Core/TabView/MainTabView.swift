//
//  TabView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            FilesContentView()
                .tabItem {
                    Label("Converter", systemImage: "gearshape")
                }
            ConverterView()
                .tabItem {
                    Label("Files", systemImage: "doc.text")
                }
        }
    }
}

#Preview {
    MainTabView()
}
