# Piomar Pomoc — utrzymanie forka

Ten katalog zawiera wszystko, co specyficzne dla naszej wersji RustDeska: proces
wydawania, aktualizację końcówek i notatki o bezpieczeństwie. Reszta repozytorium
to kod RustDeska (upstream), który aktualizujemy przez merge.

## 1. Co nasza wersja zmienia względem oryginału

| Obszar | Zmiana | Gdzie |
| --- | --- | --- |
| Serwer + klucz | Podmiana `rs-*.rustdesk.com` i `RS_PUB_KEY` na własne z sekretów | `.github/workflows/flutter-build.yml` (kroki „Patch rendezvous…") |
| Hasło domyślne | Wbudowane hasło stałe (fallback) z sekretu `DEFAULT_PERMANENT_PASSWORD` | `src/common.rs` → `apply_piomar_builtin_config()` |
| Auto-update | Wyłączony na stałe (`enable-check-update = N`) — użytkownik nie pobierze oryginalnego RustDeska | `src/common.rs` → `apply_piomar_builtin_config()` |
| Uproszczony UI | Ukryte sekcje: server / proxy / network / websocket / drukarka zdalna | `src/common.rs` → `apply_piomar_builtin_config()` |
| Nazwa/branding | Nazwa wyświetlana „Piomar Pomoc", własne ikony | `flutter/windows/runner/Runner.rc`, `AppInfo.xcconfig`, `res/` |

> **Uwaga o nazwie wewnętrznej (`APP_NAME`).** Nie zmieniamy jej z „RustDesk",
> bo steruje ona **folderem konfiguracyjnym** na końcówkach. Jej zmiana
> zresetowałaby ID i konfigurację istniejących komputerów (gabinety straciłyby
> zapamiętany dostęp). Zmieniamy tylko nazwy **wyświetlane**. Jeśli kiedyś
> zdecydujemy się na pełną zmianę `APP_NAME`, trzeba zrobić jednorazową migrację
> folderu configu na każdej działającej końcówce.

## 2. Wymagane sekrety repozytorium

`Settings → Secrets and variables → Actions`:

| Sekret | Do czego |
| --- | --- |
| `DEFAULT_RENDEZVOUS_SERVER` | Adres własnego serwera rendezvous |
| `DEFAULT_RS_PUB_KEY` | Klucz publiczny serwera |
| `DEFAULT_PERMANENT_PASSWORD` | Domyślne hasło stałe wbudowywane w build |
| `MACOS_*`, `ANDROID_*` | (opcjonalne) podpisywanie buildów |

> Hasło i klucz podawane są przez `env:` w kroku buildu, **nigdy przez `echo`/`grep`**,
> żeby nie wyciekły do logów CI.

## 3. Wydanie nowej wersji po aktualizacji RustDeska

1. **Uruchom** workflow `Sync upstream RustDesk` (Actions → Run workflow),
   podaj tag np. `1.4.8`. Zrobi merge na osobnym branchu i otworzy PR.
   - Jeśli są konflikty — rozwiąż lokalnie (instrukcja w podsumowaniu joba).
2. **Przejrzyj PR:** czy CI się buduje, czy branding przetrwał (krok „Branding
   sanity check"), czy submoduł `libs/hbb_common` przeskoczył na nową wersję.
3. **Zmerguj PR** do `master`.
4. **Zbuduj wydanie:** Actions → `Flutter Nightly Build` → Run workflow. Po
   zakończeniu pobierz artefakty (`.exe` dla Windows, `.dmg` dla macOS).

Ręczny odpowiednik kroku 1 (lokalnie):

```bash
git remote add upstream https://github.com/rustdesk/rustdesk.git   # tylko raz
git fetch upstream --tags
git checkout master
git merge 1.4.8
git submodule update --init --recursive          # WAŻNE: łatki bezpieczeństwa hbb_common
grep -rn "RustDesk\.app" --include="*.sh" --include="*.yml" --include="*.py" .
git push
```

## 4. Aktualizacja końcówek (gabinety, Windows)

Auto-update jest wyłączony, więc aktualizacje wgrywasz sam:

1. Pobierz nowy `.exe` z GitHub Actions.
2. Połącz się zdalnie z gabinetem (masz dostęp), prześlij `.exe` **oraz**
   `piomar/update-endpoint.bat` do jednego folderu.
3. Uruchom `update-endpoint.bat` jako administrator. Cicha instalacja nadpisze
   starą wersję, **zachowując ID i konfigurację** komputera.

Nowe komputery dostają hasło domyślne automatycznie (jest wbudowane w `.exe`).

## 5. Notatki bezpieczeństwa

- Hasło domyślne jest **współdzielone przez wszystkie instalacje** i da się je
  wydobyć z binarki — traktuj je jak realny sekret dostępowy do sieci gabinetów.
  Zmiana hasła = zmiana sekretu `DEFAULT_PERMANENT_PASSWORD` + przebudowa + wgranie
  na końcówki.
- Hasło domyślne to **fallback**: jeśli na hoście ustawiono lokalne hasło stałe,
  ono ma pierwszeństwo (`src/server/connection.rs`, `validate_password`).
- Aktualizuj submoduł `hbb_common` przy każdym merge — tam trafiają poprawki
  bezpieczeństwa protokołu/sieci.
