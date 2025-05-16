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
    
    // Calculamos altura aproximada sobre el contenido
    private func estimatedHeight() -> CGFloat {
        CGFloat(document.content.count) * vm.fontSize * 0.6
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                Text(document.content)
                    .font(.system(size: vm.fontSize,
                                  weight: .regular,
                                  design: .monospaced))
                    .foregroundColor(.green)
                    .offset(y: -vm.offset)
            }
            
            VStack {
                Spacer()
                
                // Controles de reproducción
                HStack(spacing: 40) {
                    // Retroceder 50 pts
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
                    
                    // Avanzar 50 pts
                    Button {
                        vm.seek(by: 50)
                    } label: {
                        Image(systemName: "forward.frame.fill")
                            .font(.largeTitle)
                    }
                }
                .foregroundColor(.white)
                .padding(.bottom, 20)
                
                // Sliders de velocidad y tamaño
                HStack {
                    VStack {
                        Text("Velocidad: \(String(format: "%.1f", vm.speed))×")
                            .foregroundColor(.white)
                        Slider(value: $vm.speed, in: 0.5...5, step: 0.1) {
                            Text("Velocidad")
                        }
                        .onChange(of: vm.speed) { _ in
                            // Reinicia timer con nueva velocidad
                            if vm.isPlaying {
                                vm.stop()
                                vm.play(totalHeight: estimatedHeight())
                            }
                        }
                    }
                    VStack {
                        Text("Tamaño: \(Int(vm.fontSize))")
                            .foregroundColor(.white)
                        Slider(value: $vm.fontSize, in: 16...64, step: 1) {
                            Text("Tamaño")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
                .background(Color.black.opacity(0.5))
            }
        }
        .onAppear {
            // Arranca automáticamente
            vm.play(totalHeight: estimatedHeight())
        }
        .onDisappear {
            vm.stop()
        }
    }
}
