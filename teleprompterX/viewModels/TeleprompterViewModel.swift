//
//  TeleprompterViewModel.swift
//  teleprompterX
//
//  Created by Fausto César Reyes on 16/05/25.
//

import Combine
import Foundation
import SwiftUI

final class TeleprompterViewModel: ObservableObject {
    // MARK: - Public bindings
    @Published var speed: Double = 1.0       // líneas por segundo
    @Published var fontSize: Double = 24     // puntos
    @Published private(set) var offset: CGFloat = 0
    @Published private(set) var isPlaying: Bool = false
    
    // MARK: - Internals
    private var timerCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()
    
    /// Arranca/reanuda el scroll
    func play(totalHeight: CGFloat) {
        guard !isPlaying else { return }
        isPlaying = true
        
        // Si no hay timer, creamos uno; si ya existía, lo mantenemos
        timerCancellable = Timer
            .publish(every: 1.0 / speed, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isPlaying else { return }
                self.offset += 1
                if self.offset > totalHeight {
                    self.offset = 0
                }
            }
        
        timerCancellable?.store(in: &cancellables)
    }
    
    /// Pausa el scroll
    func pause() {
        isPlaying = false
    }
    
    /// Avanza o retrocede una cantidad de puntos
    func seek(by delta: CGFloat) {
        offset = max(0, offset + delta)
    }
    
    /// Detiene todo y limpia
    func stop() {
        isPlaying = false
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
