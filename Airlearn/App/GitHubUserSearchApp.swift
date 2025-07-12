//
//  AirlearnApp.swift
//  Airlearn
//
//  Created by Hemanth on 11/07/25.
//

import SwiftUI
import ComposableArchitecture



@main
struct AirlearnApp: App {
    var body: some Scene {
        WindowGroup {
            SearchView(
                store: Store(
                    initialState: SearchFeature.State(),
                    reducer: { SearchFeature() }
                )
            )
        }
    }
}
