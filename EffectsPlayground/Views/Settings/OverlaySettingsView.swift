//
//  OverlaySettingsView.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI

extension FilterPSD1.Settings.Overlay: SwiftUIRepresentable {
    func makeSwiftView(binding: Binding<FilterPSD1.Settings.Overlay>) -> some View {
        Toggle("👁️ Visible?", isOn: binding.isOn)
            .fixedSize()

        Spacer(minLength: 32)

        Text(String(format: "Opacity: %.2f", binding.opacity.wrappedValue))
        Slider(value: binding.opacity, in: 0.0...1.0, step: 0.01) {
            Text(String(format: "Opacity: %.2f", binding.opacity.wrappedValue))
        } minimumValueLabel: {
            Text("0.0")
        } maximumValueLabel: {
            Text("1.0")
        }
    }
}

struct FilterPSD1SettingsOverlay_Preview: PreviewProvider {
    @State
    private static var overlay = FilterPSD1.Settings.default.overlay

    static var previews: some View {
        ScrollView {
            overlay.makeSwiftView(binding: $overlay)
        }
    }
}

