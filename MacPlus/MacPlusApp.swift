//
//  MacPlusApp.swift
//  MacPlus
//
//  Created by matthew hermans on 06/06/2024.
//

import SwiftUI

@main
struct MacPlusApp: App {
    @ObservedObject var viewModel: GlobalViewModel = GlobalViewModel()
    
    var body: some Scene {
        WindowGroup {
            HomeView(global: viewModel)
        }
        
        MenuBarExtra {
            MenuBarView(global: viewModel)
        } label: {
            Image("menuBarIcon")
        }
        .menuBarExtraStyle(.window)
    }
}
