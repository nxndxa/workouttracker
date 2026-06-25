import Foundation

enum EmailVerificationError: LocalizedError {
    case missingBackendURL
    case invalidEmail
    case invalidCode
    case server(String)

    var errorDescription: String? {
        switch self {
        case .missingBackendURL:
            "Email verification is not configured yet. Set AetherAuthBaseURL in the app Info settings."
        case .invalidEmail:
            "Enter a valid email address."
        case .invalidCode:
            "Enter the verification code from your email."
        case .server(let message):
            message
        }
    }
}

struct EmailVerificationClient {
    private let session: URLSession
    private let baseURL: URL?

    init(session: URLSession = .shared, baseURL: URL? = Self.configuredBaseURL) {
        self.session = session
        self.baseURL = baseURL
    }

    func requestCode(email: String, displayName: String) async throws -> EmailVerificationSession {
        let normalizedEmail = normalized(email)
        guard normalizedEmail.contains("@") else { throw EmailVerificationError.invalidEmail }

        let response: RequestCodeResponse = try await post(
            path: "request-code",
            body: RequestCodeRequest(email: normalizedEmail, displayName: displayName)
        )

        return EmailVerificationSession(email: normalizedEmail, expiresAt: response.expirationDate)
    }

    func verifyCode(email: String, code: String) async throws {
        let normalizedEmail = normalized(email)
        let normalizedCode = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedEmail.contains("@") else { throw EmailVerificationError.invalidEmail }
        guard normalizedCode.count >= 4 else { throw EmailVerificationError.invalidCode }

        let _: VerifyCodeResponse = try await post(
            path: "verify-code",
            body: VerifyCodeRequest(email: normalizedEmail, code: normalizedCode)
        )
    }

    private func post<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        body: RequestBody
    ) async throws -> ResponseBody {
        guard let baseURL else { throw EmailVerificationError.missingBackendURL }

        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EmailVerificationError.server("The verification server did not return a valid response.")
        }

        if !(200..<300).contains(httpResponse.statusCode) {
            let message = (try? JSONDecoder().decode(ErrorResponse.self, from: data).message)
                ?? "Email verification failed. Try again."
            throw EmailVerificationError.server(message)
        }

        return try JSONDecoder().decode(ResponseBody.self, from: data)
    }

    private func normalized(_ email: String) -> String {
        email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static var configuredBaseURL: URL? {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "AetherAuthBaseURL") as? String,
            !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }

        return URL(string: value)
    }
}

private struct RequestCodeRequest: Encodable {
    let email: String
    let displayName: String
}

private struct RequestCodeResponse: Decodable {
    let expiresAt: String?

    var expirationDate: Date? {
        guard let expiresAt else { return nil }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: expiresAt) {
            return date
        }

        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: expiresAt)
    }
}

private struct VerifyCodeRequest: Encodable {
    let email: String
    let code: String
}

private struct VerifyCodeResponse: Decodable {}

private struct ErrorResponse: Decodable {
    let message: String
}
