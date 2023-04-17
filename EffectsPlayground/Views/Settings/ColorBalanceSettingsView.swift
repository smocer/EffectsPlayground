//
//  ColorBalanceSettingsView.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI

extension PSDSettings.ColorBalance: SwiftUIRepresentable {
    func makeSwiftView(binding: Binding<PSDSettings.ColorBalance>) -> some View {
        Toggle("👁️ Visible?", isOn: binding.isOn)
            .fixedSize()

        Spacer(minLength: 32)

        Text("Midtones:")
            .font(.title3)

        Spacer(minLength: 32)

        Text(String(format: "Cyan - Red: %.2f", binding.midtones.x.wrappedValue))
        Slider(value: binding.midtones.x, in: -1.0...1.0, step: 0.01) {
            Text(String(format: "Cyan - Red: %.2f", binding.midtones.x.wrappedValue))
        } minimumValueLabel: {
            Text("-1.0")
        } maximumValueLabel: {
            Text("1.0")
        }

        Text(String(format: "Magenta - Green: %.2f", binding.midtones.y.wrappedValue))
        Slider(value: binding.midtones.y, in: -1.0...1.0, step: 0.01) {
            Text(String(format: "Magenta - Green: %.2f", binding.midtones.y.wrappedValue))
        } minimumValueLabel: {
            Text("-1.0")
        } maximumValueLabel: {
            Text("1.0")
        }

        Text(String(format: "Yellow - Blue: %.2f", binding.midtones.z.wrappedValue))
        Slider(value: binding.midtones.z, in: -1.0...1.0, step: 0.01) {
            Text(String(format: "Yellow - Blue: %.2f", binding.midtones.z.wrappedValue))
        } minimumValueLabel: {
            Text("-1.0")
        } maximumValueLabel: {
            Text("1.0")
        }
    }
}

struct PSDSettingsColorBalance_Preview: PreviewProvider {
    @State
    private static var colorBalance = PSDSettings.default.colorBalance

    static var previews: some View {
        ScrollView {
            colorBalance.makeSwiftView(binding: $colorBalance)
        }
    }
}
