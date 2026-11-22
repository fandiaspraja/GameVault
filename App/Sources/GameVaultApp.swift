//
//  GameVaultApp.swift
//  GameVault
//

import Common
import SwiftUI

@main
struct GameVaultApp: App {
  private let router = Router(resolver: Injection.shared.resolver)

  var body: some Scene {
    WindowGroup {
      MainTabView(router: router)
    }
  }
}

struct MainTabView: View {
  let router: Router

  var body: some View {
    TabView {
      NavigationStack { router.makeHomeView() }
        .tabItem { Label(L10n.Tab.home, systemImage: "gamecontroller") }

      NavigationStack { router.makeFavoriteView() }
        .tabItem { Label(L10n.Tab.favorite, systemImage: "heart") }

      NavigationStack { router.makeAboutView() }
        .tabItem { Label(L10n.Tab.about, systemImage: "person.crop.circle") }
    }
  }
}
