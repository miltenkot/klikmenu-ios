import Foundation

public enum APIError: Error, Equatable, Sendable {
    case network
    case cancelled
    case decoding
    case notFound
    case http(statusCode: Int, message: String, code: String?)

    public var userFacingMessage: String {
        switch self {
        case .network:
            return "Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie."
        case .cancelled:
            return "Żądanie zostało anulowane."
        case .decoding:
            return "Nie udało się odczytać odpowiedzi serwera."
        case .notFound:
            return "Nie znaleziono restauracji."
        case .http(let statusCode, let message, _):
            if statusCode == 429 {
                return "Wysłano zbyt wiele opinii. Spróbuj ponownie za chwilę."
            }
            if (500...599).contains(statusCode) {
                return "Serwer jest tymczasowo niedostępny. Spróbuj ponownie."
            }
            return message.isEmpty ? "Wystąpił błąd serwera (\(statusCode))." : message
        }
    }
}
