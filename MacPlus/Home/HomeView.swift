//
//  HomeView.swift
//  file automation
//
//  Created by matthew hermans on 22/05/2024.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var global: GlobalViewModel
    
    var body: some View {
        VStack() {
            Text(HomeUI.Labels.sortDownloadsExplanation)
            Toggle(HomeUI.Labels.sortDownloads, isOn: $global.sortDownloads)
                .toggleStyle(.switch)
            
            Spacer()
            
            Text("More features coming soon")
        }
        .padding()
    }
}

#Preview {
    HomeView(global: GlobalViewModel())
}
