//
//  DocumentListView.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import SwiftUI

struct DocumentListView: View {
    @StateObject private var vm: DocumentListViewModel
    private let repository: DocumentRepository

    init(repository: DocumentRepository) {
        self.repository = repository
        _vm = StateObject(wrappedValue: DocumentListViewModel(repository: repository))
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(vm.documents) { doc in
                    NavigationLink {
                        // Aquí vamos al teleprompter, pasando el documento
                        TeleprompterView(document: doc)
                    } label: {
                        Text(doc.title)
                    }
                }
                .onDelete { idxs in
                    idxs.forEach { vm.delete(vm.documents[$0]) }
                }
            }
            .navigationTitle("Mis Scripts")
            .toolbar {
                NavigationLink {
                    DocumentEditorView(vm: DocumentEditorViewModel(repository: repository))
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            .onAppear { vm.loadDocuments() }
        }
    }
}
