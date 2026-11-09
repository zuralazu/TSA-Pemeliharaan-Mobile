# Company Registration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a company create a `supervisor_umum` account with its identity and logo, and make Login and Register link to each other.

**Architecture:** Keep the existing `/api/register` route and `RegisterPage` name. Build its multipart request in a small, testable auth helper; let the screen own input, image picking, validation, loading, and response UI. Continue to source the server URL from `Env.baseUrl`.

**Tech Stack:** Flutter, `http` multipart requests, `image_picker`, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-11-06-company-registration-design.md`

## Global Constraints

- Use `POST ${Env.baseUrl}/api/register` with `multipart/form-data`.
- Include `username`, `email`, `password`, `password_confirmation`, `role=supervisor_umum`, `company_name`, `company_phone`, `company_address`, `contact_name`, and file field `logo`.
- The backend must validate fields and constrain public registration to `supervisor_umum`.
- Preserve the existing success behavior: show the server message and open Login after HTTP 201.
- Keep onboarding's existing `/register` route and use the existing `LOCAL_SERVER` configuration.
- Do not modify backend code, session storage, or environment selection.

## Review Focus

- Missing required company/account fields: form blocks submission and identifies incomplete fields.
- Invalid email or mismatched password confirmation: form blocks submission with a field-level message.
- Missing logo: form blocks submission and asks the user to select a company logo.
- Multipart mapping: logo is sent as `logo`, and the fixed public role is `supervisor_umum`.
- Existing onboarding and login navigation: onboarding opens Register; Login and Register links open the opposite screen.

---

### Task 1: Testable registration request

**Files:**
- Create: `lib/auth/register_request.dart`
- Create: `test/auth/register_request_test.dart`

**Interfaces:**
- Produces `Future<http.MultipartRequest> buildCompanyRegistrationRequest({required Uri uri, required String username, required String email, required String password, required String passwordConfirmation, required String companyName, required String companyPhone, required String companyAddress, required String contactName, required String logoPath})`.
- The request contains all fields from Global Constraints and one multipart file named `logo`.

- [x] **Step 1: Write failing multipart contract tests**

  Verify the request method and URI, each specified field including `role=supervisor_umum`, and the uploaded file field name and filename using a temporary image file.

- [x] **Step 2: Run `flutter test test/auth/register_request_test.dart` and confirm it fails because the helper is missing.**

- [x] **Step 3: Implement the request builder with `http.MultipartRequest` and `http.MultipartFile.fromPath`.**

- [x] **Step 4: Run the focused test and confirm all request contract assertions pass.**

### Task 2: Company registration form and reciprocal navigation

**Files:**
- Modify: `lib/auth/register_page.dart`
- Modify: `lib/auth/login_page.dart`
- Create: `test/auth/company_registration_flow_test.dart`
- Modify: `docs/explanation/app-flows.md`

**Interfaces:**
- `RegisterPage` remains the destination for `/register` and onboarding.
- Register uses `buildCompanyRegistrationRequest` from Task 1.
- Login links to named route `/register`; Register links to named route `/login`.

- [x] **Step 1: Add widget tests for company identity/account fields, required logo feedback, invalid email/password confirmation, and both reciprocal navigation links. Confirm the relevant tests fail before implementation.**
- [x] **Step 2: Build a scrollable Register form matching the app's blue visual style, with company name/email/phone/address, contact name, username/password/confirmation, image selection and preview, validation, loading state, and existing server success/error behavior.**
- [x] **Step 3: Add a Register link to Login and route both cross-links through the existing named routes.**
- [x] **Step 4: Run `flutter test` and confirm the complete widget and request suites pass.**
- [x] **Step 5: Update app-flow documentation to describe company registration and the links between Login and Register.**

### Final verification

- [x] Run `flutter analyze --no-fatal-infos --no-fatal-warnings`; confirm there are no analyzer errors.
- [x] Run `python scripts/check_docs_index.py`; confirm `AGENTS.md` and `docs/README.md` are in sync.
- [x] Hot reload the active emulator. Automated widget tests cover the onboarding route, reciprocal links, and scrolling layout.
