//
//  DocumentListView.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import SwiftUI

struct DocumentListView: View {
    @StateObject private var vm: DocumentListViewModel
    @State private var editingDoc: Document? = nil      // Para editar script
    @State private var newDoc: Bool = false              // Para crear nuevo script
    @State private var playingDoc: Document? = nil       // Para abrir Teleprompter
    private let repository: DocumentRepository

    init(repository: DocumentRepository) {
        self.repository = repository
        _vm = StateObject(wrappedValue: DocumentListViewModel(repository: repository))
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(vm.documents) { doc in
                    HStack {
                        Text(doc.title)
                            .foregroundColor(.primary)
                    }
                    .contentShape(Rectangle())
                    // 1) Tap para abrir teleprompter
                    .onTapGesture {
                        playingDoc = doc
                    }
                    // 2) Swipe a la derecha para editar
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        Button {
                            editingDoc = doc
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    // 3) Swipe a la izquierda para borrar
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            vm.delete(doc)
                        } label: {
                            Label("Borrar", systemImage: "trash")
                        }
                    }
                }
                .listRowSeparator(.visible)
            }
            .listStyle(.plain)
            .navigationTitle("Mis Scripts")
            .toolbar {
                Button {
                    newDoc = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }
            .onAppear {
                vm.loadDocuments()
            }
            // Cuando editingDoc deja de ser != nil (o sea, se cierra el sheet), recargamos lista
            .onChange(of: editingDoc) { newVal in
                if newVal == nil {
                    vm.loadDocuments()
                }
            }
            // Cuando newDoc pasa de true a false (se cierra el sheet de nuevo script), recargamos
            .onChange(of: newDoc) { isPresenting in
                if isPresenting == false {
                    vm.loadDocuments()
                }
            }
            // Sheet para editar un documento existente
            .sheet(item: $editingDoc) { doc in
                NavigationView {
                    DocumentEditorView(
                        vm: DocumentEditorViewModel(repository: repository, document: doc)
                    )
                }
            }
            // Sheet para crear un nuevo documento
            .sheet(isPresented: $newDoc) {
                NavigationView {
                    DocumentEditorView(
                        vm: DocumentEditorViewModel(repository: repository, document: nil)
                    )
                }
            }
            // Sheet para presentar el teleprompter con el documento seleccionado
            .sheet(item: $playingDoc) { doc in
                TeleprompterView(document: doc)
                    .ignoresSafeArea()
            }
        }
    }
}

