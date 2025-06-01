//
//  TeleprompterView.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import SwiftUI

struct TeleprompterView: View {
    let document: Document
    @StateObject private var vm = TeleprompterViewModel()
    
    // Calculamos una altura aproximada del contenido
    private func estimatedHeight() -> CGFloat {
        CGFloat(document.content.count) * vm.fontSize * 0.6
    }
    
    var body: some View {
        ZStack {
            // Fondo negro de todo el teleprompter
            Color.black.ignoresSafeArea()
            
            // ScrollView que muestra el texto moviéndose
            ScrollView(.vertical, showsIndicators: false) {
                Text(document.content)
                    .font(.system(size: vm.fontSize,
                                  weight: .regular,
                                  design: .monospaced))
                    .foregroundColor(.green)
                    .offset(y: -vm.offset)
            }
            
            // Contenedor de controles (sin ningún fondo)
            VStack {
                Spacer()
                
                // Botones de retroceder / play-pause / avanzar
                HStack(spacing: 40) {
                    // Retroceder
                    Button {
                        vm.seek(by: -50)
                    } label: {
                        Image(systemName: "backward.frame.fill")
                            .font(.largeTitle)
                    }
                    
                    // Play / Pause toggle
                    Button {
                        if vm.isPlaying {
                            vm.pause()
                        } else {
                            vm.play(totalHeight: estimatedHeight())
                        }
                    } label: {
                        Image(systemName: vm.isPlaying
                              ? "pause.circle.fill"
                              : "play.circle.fill")
                            .font(.system(size: 60))
                    }
                    
                    // Avanzar
                    Button {
                        vm.seek(by: 50)
                    } label: {
                        Image(systemName: "forward.frame.fill")
                            .font(.largeTitle)
                    }
                }
                .foregroundColor(.white)
                // NO background, todo transparente
                .padding(.bottom, 20)
                
                // Sliders de velocidad y tamaño (también sin fondo)
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Velocidad: \(String(format: "%.1f", vm.speed))×")
                            .foregroundColor(.white)
                        Slider(value: $vm.speed, in: 0.5...5, step: 0.1) {
                            Text("Velocidad")
                        }
                        .onChange(of: vm.speed) { _ in
                            if vm.isPlaying {
                                vm.stop()
                                vm.play(totalHeight: estimatedHeight())
                            }
                        }
                    }
                    VStack(spacing: 4) {
                        Text("Tamaño: \(Int(vm.fontSize)) pt")
                            .foregroundColor(.white)
                        Slider(value: $vm.fontSize, in: 16...64, step: 1) {
                            Text("Tamaño")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                // NO background aquí tampoco: queda totalmente transparente
            }
        }
        .onAppear {
            // Arrancamos de una vez
            vm.play(totalHeight: estimatedHeight())
        }
        .onDisappear {
            vm.stop()
        }
    }
}
