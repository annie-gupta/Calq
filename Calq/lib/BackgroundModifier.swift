//
//  BackgroundModifier.swift
//  Calq
//
//  Created by Kiara on 08.12.23.
//

import SwiftUI

struct BackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            Color.red
            content
        }.ignoresSafeArea()
    }
}
