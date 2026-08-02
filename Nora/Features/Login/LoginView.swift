import SwiftUI

struct LoginView: View {
    @Environment(AppEnvironment.self) private var environment
    @State private var email = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @FocusState private var focusedField: Field?

    private enum Field { case email, password }
    private enum ScrollTarget { case continueButton }

    var body: some View {
        @Bindable var authSession = environment.authSession

        ZStack {
            Image("WelcomeCity")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.08), location: 0),
                    .init(color: .noraBackground.opacity(0.45), location: 0.38),
                    .init(color: .noraBackground.opacity(0.96), location: 0.72),
                    .init(color: .noraBackground, location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: focusedField == nil ? 210 : Spacing.xl)
                        Image("NoraWordmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 112)
                            .accessibilityLabel("Nora")
                        Spacer().frame(height: Spacing.xl)
                        heading
                        Spacer().frame(height: Spacing.xxl)
                        form(authSession: authSession)
                        Spacer().frame(height: Spacing.xl)
                        continueButton(authSession: authSession)
                            .id(ScrollTarget.continueButton)
                        Spacer(minLength: Spacing.xl)
                    }
                    .padding(.horizontal, Spacing.xxl)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, field in
                    guard field != nil else { return }
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(300))
                        withAnimation(.easeOut(duration: 0.25)) {
                            proxy.scrollTo(ScrollTarget.continueButton, anchor: .bottom)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var heading: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Welcome back")
                .font(.noraLargeTitle)
                .foregroundStyle(.white)
            Text("Your day, already distilled.")
                .font(.noraBody)
                .foregroundStyle(.white.opacity(0.66))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func form(authSession: AuthSessionStore) -> some View {
        VStack(alignment: .leading, spacing: Spacing.lg) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                fieldLabel("Email")
                loginField(
                    title: "name@example.com",
                    symbol: "envelope",
                    text: $email,
                    field: .email,
                    contentType: .username
                )
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .onSubmit { focusedField = .password }
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                fieldLabel("Password")
                passwordField
            }

            if let message = authSession.errorMessage {
                Label(message, systemImage: "exclamationmark.circle.fill")
                    .font(.noraSupporting)
                    .foregroundStyle(Color.noraCritical)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

        }
    }

    private func continueButton(authSession: AuthSessionStore) -> some View {
        Button(action: submit) {
            ZStack {
                if authSession.isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Text("Continue")
                        .font(.noraCardTitle)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundStyle(.white)
            .background(
                Color.noraAccent.opacity(canSubmit ? 1 : 0.38),
                in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
            )
        }
        .buttonStyle(.plain)
        .disabled(!canSubmit || authSession.isSubmitting)
        .animation(.easeOut(duration: 0.2), value: canSubmit)
    }

    private var passwordField: some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: "lock")
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 20)

            Group {
                if isPasswordVisible {
                    TextField(
                        "",
                        text: $password,
                        prompt: placeholder("Enter your password")
                    )
                } else {
                    SecureField(
                        "",
                        text: $password,
                        prompt: placeholder("Enter your password")
                    )
                }
            }
            .textContentType(.password)
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit { submit() }

            Button {
                isPasswordVisible.toggle()
            } label: {
                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    .foregroundStyle(.white.opacity(0.52))
                    .frame(width: TouchTarget.minimum, height: TouchTarget.minimum)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
        }
        .modifier(LoginFieldStyle(isFocused: focusedField == .password))
    }

    private func fieldLabel(_ title: String) -> some View {
        Text(title)
            .font(.noraSupporting.weight(.medium))
            .foregroundStyle(.white.opacity(0.82))
    }

    private func loginField(
        title: String,
        symbol: String,
        text: Binding<String>,
        field: Field,
        contentType: UITextContentType
    ) -> some View {
        HStack(spacing: Spacing.md) {
            Image(systemName: symbol)
                .foregroundStyle(.white.opacity(0.5))
                .frame(width: 20)
            TextField("", text: text, prompt: placeholder(title))
                .textContentType(contentType)
                .focused($focusedField, equals: field)
        }
        .modifier(LoginFieldStyle(isFocused: focusedField == field))
    }

    private func placeholder(_ text: String) -> Text {
        Text(text)
            .foregroundColor(.white.opacity(0.58))
    }

    private var canSubmit: Bool {
        email.contains("@") && !password.isEmpty
    }

    private func submit() {
        guard canSubmit, !environment.authSession.isSubmitting else { return }
        focusedField = nil
        Task { await environment.authSession.login(email: email, password: password) }
    }
}

private struct LoginFieldStyle: ViewModifier {
    let isFocused: Bool

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, Spacing.base)
            .frame(minHeight: 56)
            .foregroundStyle(.white)
            .background(
                Color.white.opacity(isFocused ? 0.12 : 0.08),
                in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                    .stroke(
                        isFocused ? Color.noraAccent.opacity(0.9) : Color.white.opacity(0.12),
                        lineWidth: isFocused ? 1.5 : 1
                    )
            }
            .animation(.easeOut(duration: 0.18), value: isFocused)
    }
}

#Preview {
    LoginView()
        .environment(AppEnvironment.preview())
}
