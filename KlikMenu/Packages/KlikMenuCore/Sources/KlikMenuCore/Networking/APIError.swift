import Foundation

public enum APIError: Error, Equatable, Sendable {
    case network
    case cancelled
    case decoding
    case notFound
    case http(statusCode: Int, message: String, code: String?)

    public var userFacingMessage: LocalizedStringResource {
        switch self {
        case .network:
            LocalizedStringResource(
                "Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.",
                bundle: #bundle
            )
        case .cancelled:
            LocalizedStringResource("Żądanie zostało anulowane.", bundle: #bundle)
        case .decoding:
            LocalizedStringResource(
                "Nie udało się odczytać odpowiedzi serwera.",
                bundle: #bundle
            )
        case .notFound:
            LocalizedStringResource("Nie znaleziono restauracji.", bundle: #bundle)
        case .http(let statusCode, let message, _):
            if statusCode == 429 {
                LocalizedStringResource(
                    "Wysłano zbyt wiele opinii. Spróbuj ponownie za chwilę.",
                    bundle: #bundle
                )
            } else if (500...599).contains(statusCode) {
                LocalizedStringResource(
                    "Serwer jest tymczasowo niedostępny. Spróbuj ponownie.",
                    bundle: #bundle
                )
            } else if message.isEmpty {
                LocalizedStringResource(
                    "Wystąpił błąd serwera (\(statusCode)).",
                    bundle: #bundle
                )
            } else {
                LocalizedStringResource(stringLiteral: message)
            }
        }
    }
}
