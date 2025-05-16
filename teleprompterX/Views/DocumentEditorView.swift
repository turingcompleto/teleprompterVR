//
//  DocumentEditorView.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import SwiftUI

struct DocumentEditorView: View {
    @StateObject var vm: DocumentEditorViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Título", text: $vm.title)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            // Editor multilinea para el contenido
            TextEditor(text: $vm.content)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 200)
                .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3)))
                .padding(.horizontal)
                .onAppear {
                    // TextEditor estuvo disponible desde iOS 14 para multiline editing :contentReference[oaicite:1]{index=1}
                }
            
            Spacer()
            
            Button(action: {
                vm.saveDocument()
            }) {
                Text("Guardar")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.title.isEmpty || vm.content.isEmpty
                                ? Color.gray.opacity(0.5)
                                : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(vm.title.isEmpty || vm.content.isEmpty)
            .padding()
        }
        .navigationTitle("Nuevo Documento")
        // Cuando termine de guardar, cerramos la vista
        .onChange(of: vm.didSave) { saved in
            if saved {
                presentationMode.wrappedValue.dismiss()
            }
        }
        // Mostrar alerta en caso de error
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
