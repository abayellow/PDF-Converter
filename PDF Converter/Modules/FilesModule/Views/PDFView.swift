//
//  PDFView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct PDFView: View {
    let preview: UIImage
    let name: String
    let date: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy | hh:mm a" 
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            Image(uiImage: preview)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 60)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                Text(dateFormatter.string(from: date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    PDFView(preview: UIImage(named: "apple")!, name: "Example PDF", date: Date())
}


