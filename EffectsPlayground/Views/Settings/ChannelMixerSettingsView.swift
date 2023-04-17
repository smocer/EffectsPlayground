//
//  ChannelMixerSettingsView.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI

extension PSDSettings.ChannelMixer: SwiftUIRepresentable {
    func makeSwiftView(binding: Binding<PSDSettings.ChannelMixer>) -> some View {
        Toggle("👁️ Visible?", isOn: binding.isOn)
            .fixedSize()

        Spacer(minLength: 32)

        Text("Output channel - Red:")
            .font(.title3)

        Spacer(minLength: 32)

        Group {
            Text(String(format: "Red: %.2f", binding.redOutput.x.wrappedValue))
            Slider(value: binding.redOutput.x, in: -2.0...2.0, step: 0.01) {
                Text(String(format: "Red: %.2f", binding.redOutput.x.wrappedValue))
            } minimumValueLabel: {
                Text("-2.0")
            } maximumValueLabel: {
                Text("2.0")
            }
        }

        Group {
            Text(String(format: "Green: %.2f", binding.redOutput.y.wrappedValue))
            Slider(value: binding.redOutput.y, in: -2.0...2.0, step: 0.01) {
                Text(String(format: "Green: %.2f", binding.redOutput.y.wrappedValue))
            } minimumValueLabel: {
                Text("-2.0")
            } maximumValueLabel: {
                Text("2.0")
            }
        }

        Group {
            Text(String(format: "Blue: %.2f", binding.redOutput.z.wrappedValue))
            Slider(value: binding.redOutput.z, in: -2.0...2.0, step: 0.01) {
                Text(String(format: "Blue: %.2f", binding.redOutput.z.wrappedValue))
            } minimumValueLabel: {
                Text("-2.0")
            } maximumValueLabel: {
                Text("2.0")
            }
        }

        Group {
            Text(String(format: "Total: %.2f", binding.redOutput.w.wrappedValue))
            Slider(value: binding.redOutput.w, in: -2.0...2.0, step: 0.01) {
                Text(String(format: "Total: %.2f", binding.redOutput.w.wrappedValue))
            } minimumValueLabel: {
                Text("-2.0")
            } maximumValueLabel: {
                Text("2.0")
            }
        }
    }
}

struct PSDSettingsPhotoChannelMixer: PreviewProvider {
    @State
    private static var channelMixer = PSDSettings.default.channelMixer

    static var previews: some View {
        ScrollView {
            channelMixer.makeSwiftView(binding: $channelMixer)
        }
    }
}

