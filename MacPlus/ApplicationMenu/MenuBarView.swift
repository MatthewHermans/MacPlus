//
//  MenuBarView.swift
//  MacPlus
//
//  Created by matthew hermans on 07/06/2024.
//

import SwiftUI

struct MenuBarView: View {
    @ObservedObject var global: GlobalViewModel
    var body: some View {
        Form {
            Toggle("Sort Downloads Folder", isOn: $global.sortDownloads)
        }
        .toggleStyle(.switch)
        .frame(width: 225,
               height: 50)
    }
}

#Preview {
    MenuBarView(global: GlobalViewModel())
}
