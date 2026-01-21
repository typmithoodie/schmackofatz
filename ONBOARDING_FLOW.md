# Onboarding Flow - Gast vs. Angemeldete Benutzer

## Aktueller Flow

### Für Gast-Benutzer:
1. **Willkommensbildschirm** → "Als Gast fortfahren" 
2. **Onboarding** → 4 Fragen zu Kochgewohnheiten beantworten
3. **Haupt-App** → NavigationPage mit allen Features

### Für angemeldete Benutzer:
1. **Willkommensbildschirm** → "Anmelden" oder "Registrieren"
2. **Authentifizierung** → Login/Signup durchführen
3. **Onboarding** → Gleiche 4 Fragen beantworten
4. **Haupt-App** → NavigationPage mit allen Features

## Wie es funktioniert

### start_decider.dart Logik:
```dart
// Wenn angemeldet ODER Gast-Modus
if (isSignedIn || isGuestMode) {
  return FutureBuilder<bool>(
    future: _isOnboardingDone(),  // Prüft SharedPreferences
    builder: (context, onboardingSnapshot) {
      // Wenn Onboarding noch nicht gemacht → OnboardingScreen
      // Wenn Onboarding schon gemacht → NavigatorPage
    },
  );
}
```

### SharedPreferences Speicherung:
- `onboarding_done`: true/false
- `guest_mode`: true/false

## Vorteile dieses Flows

✅ **Konsistente Erfahrung**: Alle Benutzer (Gast + angemeldet) bekommen personalisierte Rezepte
✅ **Daten sammeln**: Onboarding-Antworten werden für beide Benutzertypen genutzt
✅ **Spätere Registrierung**: Gast-Benutzer können später ein Konto erstellen
✅ **Nahtloser Übergang**: Keine Unterbrechung der Benutzererfahrung

## Onboarding-Fragen

1. **Kochgewohnheiten**: Wie oft kochst du?
2. **Lebensmittelverschwendung**: Wirfst du oft Lebensmittel weg?
3. **Einkaufsplanung**: Wie planst du deine Einkäufe?
4. **Rezept-Ideen**: Woher holst du Ideen für Rezepte?

## Nach dem Onboarding

- Gast-Benutzer: Nutzen alle Features ohne Konto
- Angemeldete Benutzer: Zusätzlich Profil-Verwaltung und Daten-Synchronisation

Dieser Flow stellt sicher, dass sowohl Gast- als auch angemeldete Benutzer eine personalisierte Erfahrung haben!
