//
//  DocumentEditorView.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

// Views/DocumentEditorView.swift

import SwiftUI

struct DocumentEditorView: View {
    @StateObject var vm: DocumentEditorViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Título", text: $vm.title)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            TextEditor(text: $vm.content)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 200)
                .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3)))
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                vm.saveDocument()
            }) {
                Text("Guardar")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid
                                ? Color.green
                                : Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!isFormValid)
            .padding()
        }
        .navigationTitle(originalTitle)
        .onChange(of: vm.didSave) { saved in
            if saved {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
    
    // Cuando estamos editando, mostrar título distinto
    private var originalTitle: String {
        vm.originalDocument != nil ? "Editar Documento" : "Nuevo Documento"
    }
    
    // Validamos que no queden sólo espacios
    private var isFormValid: Bool {
        let t = vm.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let c = vm.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return !t.isEmpty && !c.isEmpty
    }
}
