//
//  MergePDFSelectorView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

import SwiftUI

struct MergePDFSelectorView: View {
    var pdfs: [PDFDocumentItem]
    var onSelect: (PDFDocumentItem) -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            Text("Select document to merge with")
                .font(.headline)
                .padding()

            ScrollView {
                LazyVStack {
                    ForEach(pdfs) { doc in
                        PDFView(preview: doc.preview, name: doc.name, date: doc.date)
                            .onTapGesture { onSelect(doc) }
                    }
                }
                .padding()
            }

            Button("Cancel") { onCancel() }
                .padding()
        }
    }
}
