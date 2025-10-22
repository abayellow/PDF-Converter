//
//  EmtyView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(.pdf)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .padding(20)

            Text("There's nothing here yet")
                .font(.headline)

            Text("Click on \"+\" to convert your files to PDF, formatting and saving of received documents")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300) 
        }
        .padding()
    }
}

#Preview {
    EmptyStateView()
        .padding()
}
