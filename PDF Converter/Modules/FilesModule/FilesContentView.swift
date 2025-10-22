//
//  FilesView.swift
//  PDF Converter
//
//  Created by Alexander Abanshin on 21.10.2025.
//

import SwiftUI

struct IdentifiableURL: Identifiable, Equatable {
    let id = UUID()
    let url: URL
}

struct FilesContentView: View {
    @StateObject private var vm = FilesViewModel()
    @State private var selectedPDF: IdentifiableURL? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(title: "PDF Converter", subtitile: "Convert photos to PDF")
            
            if vm.pdfDocuments.isEmpty {
                EmptyStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.gray.opacity(0.1))
            } else {
                PDFListView(
                    pdfDocuments: vm.pdfDocuments,
                    onShare: vm.share(_:),
                    onDelete: vm.delete(_:),
                    onMerge: vm.selectPDFForMerge(_:),
                    onOpen: { url in
                        selectedPDF = IdentifiableURL(url: url)
                    }
                )
                .background(Color.gray.opacity(0.1))
            }
            
            CustomTabBar { vm.showSheet.toggle() }
        }
        .background(Color.gray.opacity(0.1))
        
        // MARK: - Photo/File Picker
        .sheet(isPresented: $vm.showSheet) {
            ChoosePhotoView { name, images, files in
                vm.addPDF(from: images, name: name)

            }
        }
        
        // MARK: - PDF Viewer
        .sheet(item: $selectedPDF) { identifiablePDF in
            PDFReaderView(pdfURL: identifiablePDF.url)
        }
        
        // MARK: - Merge PDF Selector
        .sheet(isPresented: $vm.showMergeSelector) {
            MergePDFSelectorView(
                pdfs: vm.pdfDocuments.filter { $0.id != vm.selectedPDFForMerge?.id },
                onSelect: vm.mergePDFs(with:),
                onCancel: {
                    vm.showMergeSelector = false
                    vm.selectedPDFForMerge = nil
                }
            )
        }
    }
}

#Preview {
    FilesContentView()
}

