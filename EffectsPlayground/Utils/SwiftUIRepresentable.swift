//
//  SwiftUIRepresentable.swift
//  EffectsPlayground
//
//  Created by Egor Butyrin on 17.04.2023.
//

import SwiftUI

protocol SwiftUIRepresentable {
    associatedtype Content: View

    @ViewBuilder
    func makeSwiftView(binding: Binding<Self>) -> Content
}
