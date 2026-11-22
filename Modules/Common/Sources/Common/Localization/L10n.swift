//
//  L10n.swift
//  Common
//
//  Seluruh teks antarmuka aplikasi. Terjemahan ada di
//  Resources/id.lproj dan Resources/en.lproj (Localizable.strings).
//

import Foundation

public enum L10n {
  /// Bundle yang memuat file terjemahan (dipakai juga oleh unit test).
  public static let bundle = Bundle.module

  /// Bahasa yang sedang dipakai aplikasi ("id" atau "en").
  public static var languageCode: String {
    bundle.preferredLocalizations.first ?? "id"
  }

  public static var locale: Locale {
    Locale(identifier: languageCode)
  }

  public static func string(_ key: String) -> String {
    NSLocalizedString(key, bundle: bundle, comment: "")
  }

  public static func format(_ key: String, _ arguments: CVarArg...) -> String {
    String(format: string(key), locale: locale, arguments: arguments)
  }

  // MARK: - Umum

  public enum General {
    public static var untitled: String { string("general.untitled") }
    public static var tba: String { string("general.tba") }
    public static var ok: String { string("general.ok") }
    public static var errorTitle: String { string("general.error.title") }
    public static var retry: String { string("general.retry") }
    public static var loadFailed: String { string("general.load.failed") }
    public static func ratingAccessibility(_ rating: String) -> String { format("general.rating.accessibility", rating) }
  }

  public enum Tab {
    public static var home: String { string("tab.home") }
    public static var favorite: String { string("tab.favorite") }
    public static var about: String { string("tab.about") }
  }

  // MARK: - Fitur

  public enum Home {
    public static var title: String { string("home.title") }
    public static var searchPrompt: String { string("home.search.prompt") }
    public static var allGenres: String { string("home.genre.all") }
    public static var sort: String { string("home.sort") }
    public static var sortRelevance: String { string("home.sort.relevance") }
    public static var sortPopular: String { string("home.sort.popular") }
    public static var sortRating: String { string("home.sort.rating") }
    public static var sortNewest: String { string("home.sort.newest") }
    public static var sortName: String { string("home.sort.name") }
    public static var noResultTitle: String { string("home.empty.search.title") }
    public static func noResultMessage(_ query: String) -> String { format("home.empty.search.message", query) }
    public static var emptyTitle: String { string("home.empty.title") }
    public static var emptyMessage: String { string("home.empty.message") }
  }

  public enum Detail {
    public static var title: String { string("detail.title") }
    public static var loading: String { string("detail.loading") }
    public static func reviews(_ count: String) -> String { format("detail.reviews", count) }
    public static var metascore: String { string("detail.metascore") }
    public static var release: String { string("detail.release") }
    public static var playtime: String { string("detail.playtime") }
    public static func playtimeValue(_ hours: Int) -> String { format("detail.playtime.value", hours) }
    public static var developer: String { string("detail.developer") }
    public static var genres: String { string("detail.genres") }
    public static var platforms: String { string("detail.platforms") }
    public static var screenshots: String { string("detail.screenshots") }
    public static var about: String { string("detail.about") }
    public static var aboutEmpty: String { string("detail.about.empty") }
    public static var readMore: String { string("detail.read.more") }
    public static var readLess: String { string("detail.read.less") }
    public static var website: String { string("detail.website") }
    public static var addFavorite: String { string("detail.favorite.add") }
    public static var removeFavorite: String { string("detail.favorite.remove") }
    public static var addedToast: String { string("detail.favorite.added") }
    public static var removedToast: String { string("detail.favorite.removed") }
    public static var close: String { string("detail.gallery.close") }
    public static func galleryCounter(_ index: Int, _ total: Int) -> String { format("detail.gallery.counter", index, total) }
  }

  public enum Favorite {
    public static var title: String { string("favorite.title") }
    public static func count(_ total: Int) -> String { format("favorite.count", total) }
    public static var emptyTitle: String { string("favorite.empty.title") }
    public static var emptyMessage: String { string("favorite.empty.message") }
    public static var delete: String { string("favorite.delete") }
  }

  public enum About {
    public static var title: String { string("about.title") }
    public static var profileSection: String { string("about.section.profile") }
    public static var email: String { string("about.email") }
    public static var city: String { string("about.city") }
    public static var course: String { string("about.course") }
    public static var appSection: String { string("about.section.app") }
    public static var version: String { string("about.version") }
    public static var dataSource: String { string("about.source") }
    public static var language: String { string("about.language") }
    public static var languageHint: String { string("about.language.hint") }
    public static func photo(_ name: String) -> String { format("about.photo.accessibility", name) }
  }

  public enum Errors {
    public static var noConnection: String { string("error.no.connection") }
    public static var unauthorized: String { string("error.unauthorized") }
    public static var server: String { string("error.server") }
    public static var decoding: String { string("error.decoding") }
    public static var database: String { string("error.database") }
    public static var notFound: String { string("error.not.found") }
    public static var invalidRequest: String { string("error.invalid.request") }
    public static var unknown: String { string("error.unknown") }
  }
}
