//
//  PDFListView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 22.10.2025.
//

import SwiftUI

import SwiftUI

struct PDFListView: View {
    var pdfDocuments: [PDFDocumentItem]
    var onShare: (PDFDocumentItem) -> Void
    var onDelete: (PDFDocumentItem) -> Void
    var onMerge: (PDFDocumentItem) -> Void
    var onOpen: (URL) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(pdfDocuments) { doc in
                    PDFListRow(
                        document: doc,
                        onOpen: { onOpen(doc.url) },
                        onShare: { onShare(doc) },
                        onMerge: { onMerge(doc) },
                        onDelete: { onDelete(doc) }
                    )
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.1))
    }
}

struct PDFListRow: View {
    let document: PDFDocumentItem
    let onOpen: () -> Void
    let onShare: () -> Void
    let onMerge: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onOpen) {
            PDFView(preview: document.preview, name: document.name, date: document.date)
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(action: onShare) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Button(action: onMerge) {
                Label("Merge", systemImage: "link")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}



// MARK: - View Modifier
extension View {
    func cardStyle() -> some View {
        self
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Preview
#Preview {
    let samplePDFs = [
        PDFDocumentItem(
            name: "Example 1",
            url: URL(string: "https://example.com/1.pdf")!,
            preview: UIImage(systemName: "doc.text")!,
            date: Date()
        ),
        PDFDocumentItem(
            name: "Example 2",
            url: URL(string: "https://example.com/2.pdf")!,
            preview: UIImage(systemName: "doc.richtext")!,
            date: Date()
        )
    ]

    PDFListView(
        pdfDocuments: samplePDFs,
        onShare: { _ in print("share") },
        onDelete: { _ in print("delete") },
        onMerge: { _ in print("merge") },
        onOpen: { _ in print("open") }
    )
}

#Preview {
    let samplePDFs = [
        PDFDocumentItem(name: "Example 1", url: URL(string: "https://example.com")!, preview: UIImage(systemName: "doc.text")!, date: Date()),
        PDFDocumentItem(name: "Example 2", url: URL(string: "https://example.com")!, preview: UIImage(systemName: "doc.text")!, date: Date())
    ]
    
    PDFListView(
        pdfDocuments: samplePDFs,
        onShare: { _ in },
        onDelete: { _ in },
        onMerge: { _ in },
        onOpen: { _ in }
    )
}
