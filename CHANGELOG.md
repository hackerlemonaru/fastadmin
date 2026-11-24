# Changelog

All notable changes to FastAdmin are documented in this file.

## 0.10.0

### Features

- **Form field labels**: `list_display_labels` now also applies to add/change
  form fields (and inline forms), not only list-page column headers. An
  explicit `label` in `formfield_overrides` widget props still wins.
- **Localization**: the admin UI is fully translatable. Bundled languages:
  English, Russian, German, Spanish, French and Chinese. New `ADMIN_LANGUAGE`
  setting selects the default language (`en` by default; set to empty to
  auto-detect from the browser). Users can switch the language from the header
  settings menu; the choice is persisted in the browser and also switches the
  Ant Design and dayjs locales (dates, pagination, pickers).
- **Theme modes**: the header settings menu now offers Light, Dark and System
  themes. System (the default) follows the OS appearance live via
  `prefers-color-scheme`.

### Frontend

- **Apple-like design polish**: transparent macOS-style sidebar, frosted-glass
  dropdowns/popovers/pickers, blurred modal backdrop, overlay scrollbars,
  accent-tinted text selection, subtle table row hover and refined button
  radii. The configured `primary_color` remains the accent everywhere.
- **antd deprecations fixed**: `Collapse expandIconPosition` →
  `expandIconPlacement`, `Transfer listStyle` → `styles.section`,
  `Descriptions.Item` JSX children / `contentStyle` → the `items` API with
  `styles.content`.
- **i18next is now registered via `initReactI18next`** so components resolve
  translations (with interpolation) even outside an explicit
  `I18nextProvider`.

## 0.9.1

### Security

- **Passwords**: saving a user from the change form no longer destroys the
  password by re-hashing the stored hash. The change form displayed the current
  hash in the read-only password field and echoed it back on Save, and the
  save hook hashed it again. The frontend now excludes `PasswordInput` fields
  from the change payload, and the backend additionally drops a submitted
  password value that matches the stored one, so third-party clients that echo
  the hash are also safe. Passwords are changed only via the change-password
  endpoint / modal.

## 0.9.0

### Features

- **Column labels**: new `list_display_labels` ModelAdmin attribute
  (`{"field": "Header"}`) overrides or translates auto-generated list-page
  column titles. Sorting, filtering and data binding stay keyed by the field
  name.
- **Actions without selection**: `@action(requires_selection=False)` enables
  the Apply button without selecting rows; the action receives an empty `ids`
  list and should treat it as "all objects".

### Frontend

- **Apple-like design refresh**: frosted-glass sticky header with hairline
  borders (the configured `primary_color` now serves as the accent instead of
  the header background), larger continuous corner radii, softer diffuse
  shadows, `#f5f5f7`/`#161617` layout backgrounds, tighter letter spacing and
  transparent table headers. The rich-text editor accent follows
  `primary_color` instead of a hardcoded teal.
- **Dependencies**: antd 6.5.1, i18next 26, react-i18next 17, vite 8, jsdom 29,
  TypeScript 6.0, vitest 4.1.10, eslint 10.7; `quill-delta` added to satisfy a
  peer dependency and `baseUrl` removed from `tsconfig.json` (deprecated in
  TypeScript 6).

## 0.8.3

Correctness and security fixes from a full-codebase review. The only public API
addition is the backward-compatible `has_action_permission` model-admin hook.

### Security

- **Actions**: the `action` endpoint now enforces permissions server-side via a
  new `has_action_permission` hook (defaults to `has_change_permission`), so a
  read-only admin can no longer run a registered bulk action. Override the hook
  to allow a read-only user to run a specific non-mutating action.
- **Passwords**: editing a user with an empty password field no longer
  overwrites the stored hash with a hash of the empty string.
- **JWT**: signing and verifying are refused when `ADMIN_SECRET_KEY` is unset or
  empty, closing an empty-secret token-forgery path and returning a clear
  configuration error instead of an HTTP 500.

### Backend

- **All ORMs**: a legitimate primary key / user id of `0` no longer misroutes a
  save (update vs insert) or is rejected as unauthenticated.
- **SQLAlchemy**: `get_model_pk_name` resolves non-autoincrement primary keys
  (UUID/string) instead of falling back to `"id"`; `contains`/`icontains`
  filters cast to text so they work on integer columns; the primary key is
  excluded from `required`; and the generated primary key is read before commit
  so create/update is safe under the default `expire_on_commit=True`.
- **Tortoise / Django / Yara**: a falsy database default (`0`/`False`/`""`) no
  longer marks a field as required, and the primary key is excluded from
  `required`. Tortoise enum options now emit the scalar value, and Django choice
  options no longer swap the stored value with the human-readable label.
- **Serialization**: a field listed in both `exclude` and `list_display` now
