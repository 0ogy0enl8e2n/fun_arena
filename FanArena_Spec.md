# FanArena_Spec.md

## 1. App Summary

**App Name:** FanArena  
**Platform:** Flutter (iOS + Android)  
**Minimum OS:** iOS 16+, Android 8.0+  
**Orientation:** Portrait only  
**Connectivity:** Fully offline by default  
**Primary Audience:** Sports fans who follow matches, tournaments, clubs, and competition days across multiple sports.  
**Core Problem:** Many fans want a simple companion app to track favorite teams, save match-day plans, record reactions and predictions, and organize competition-related notes without needing accounts, ads, or live-data dependencies.  
**Core Value:** FanArena is a clean offline sports companion that helps users organize fandom activity around competitions: favorite teams, match-day schedules, predictions, watch plans, venue notes, fan journal entries, and tournament collections.

### Product Positioning
FanArena is not a betting app, fantasy gambling app, or ticketing marketplace. It is a neutral sports-fan organizer focused on personal tracking, journaling, planning, and collection.

### Assumptions
- The app is intentionally offline-first and does not include live scores.
- All user-generated content is stored locally.
- The app supports multiple sports categories, such as football, basketball, хоккей, tennis, volleyball, and esports-style tournaments, but all in-app text remains in English.
- The visual language is neutral, modern, and sports-inspired without using any specific club, league, or bookmaker branding.

---

## 2. Feature List

### MVP Features
1. **Mandatory onboarding (4 screens)**
   - Welcome
   - Favorite sports selection
   - Favorite teams / fan interests setup
   - Notification preference explanation (local reminders only) + finish

2. **Home dashboard**
   - Personalized greeting
   - Quick actions
   - Upcoming saved match-day cards
   - Favorite teams block
   - Recent fan journal entries
   - Empty state when no data exists

3. **My Teams**
   - Add favorite teams/clubs manually
   - Assign sport, color tag, short note, rivalry tag, and priority
   - Mark teams as favorites
   - Filter by sport

4. **Match Planner**
   - Create planned match entries manually
   - Add opponent, date, time, location/watch method, tournament, reminder toggle, and notes
   - Track status: Planned / Watched / Missed

5. **Predictions Board**
   - Create personal predictions for saved matches
   - Store predicted winner, confidence level, and short reasoning
   - Mark prediction result later as Correct / Incorrect / Pending

6. **Fan Journal**
   - Save text entries after matches or tournaments
   - Attach mood tag and team reference
   - View entries in reverse chronological order

7. **Tournament Collections**
   - Create tournament cards manually
   - Save season/year, sport, favorite participants, and notes
   - Pin important tournaments

8. **Local reminders**
   - Optional local notification reminders for saved match plans
   - Entirely device-based, no server sync

9. **Settings**
   - Edit profile nickname
   - Light / Dark / System theme
   - Reset onboarding
   - Export / import local JSON backup
   - Clear all data

### Optional Enhancements
1. Fan streak counter for journal activity
2. Simple offline stats summary (planned matches, watched matches, correct predictions)
3. Favorite team mood timeline
4. Share as plain-text summary
5. Home widgets in future phase

---

## 3. Screen Map + Navigation Flow

## App Structure
The app uses a **bottom navigation bar** with 5 main tabs and secondary push navigation.

### Primary Tabs
1. **Home**
2. **Teams**
3. **Planner**
4. **Journal**
5. **Settings**

### Secondary Screens
- Onboarding flow
- Add/Edit Team
- Match Details
- Add/Edit Match
- Add/Edit Prediction
- Prediction List
- Add/Edit Journal Entry
- Tournament List
- Add/Edit Tournament
- Stats Summary
- Export/Import Sheet/Dialog
- Reset Confirmation Dialogs

### Navigation Flow
1. Launch app
2. Check `onboarding_completed`
3. If false → onboarding flow
4. If true → Home tab
5. From Home, user can deep-link via buttons to Teams, Planner, Predictions, Journal, or Tournaments
6. Detail and editor screens open via `Navigator.push`
7. Destructive actions use confirmation dialogs or bottom sheets

---

## 4. Detailed Per-Screen Specs

## 4.1 Splash / App Launch

### Purpose
Quickly initialize local storage, theme mode, onboarding state, and cached user preferences.

### Layout Blocks
- Full-screen neutral background
- Center app icon mark
- Small loading indicator

### States
- **Loading:** initialize storage and notification permission state cache
- **Success:** route to Onboarding or Main App
- **Error:** show retry view with “Retry” button

### Actions
- No direct interaction except retry on failure

---

## 4.2 Onboarding Screen 1 — Welcome

### Purpose
Introduce the app concept and position it as a personal sports-fan organizer.

### Layout Blocks
- Top illustration
- Title
- Supporting description
- Page indicator
- Primary CTA: `Continue`
- Secondary CTA: `Skip`

### Content
- Title: `Your personal sports companion`
- Body: `Plan match days, follow your favorite teams, save predictions, and keep your fan memories in one place.`

### Actions
- Continue → next onboarding screen
- Skip → final onboarding confirmation screen

---

## 4.3 Onboarding Screen 2 — Choose Sports

### Purpose
Collect favorite sports categories.

### Layout Blocks
- Header text
- Multi-select chip grid
- Continue button

### Components
- Chips: Football, Basketball, Hockey, Tennis, Volleyball, Baseball, Motorsport, Esports, Other

### Validation
- At least 1 sport required unless user taps Skip

### Stored Output
- `favorite_sports`

---

## 4.4 Onboarding Screen 3 — Fan Interests

### Purpose
Collect nickname and initial fan preferences.

### Layout Blocks
- Text field: nickname
- Toggle: enable match reminders
- Optional text field: favorite team to start with
- Continue button

### Validation
- Nickname max 24 chars
- Trim whitespace
- Empty nickname allowed; fallback name is `Fan`

### Stored Output
- `profile_nickname`
- `reminders_enabled_default`
- optional starter team draft

---

## 4.5 Onboarding Screen 4 — Ready to Start

### Purpose
Confirm what the app offers and finish onboarding.

### Layout Blocks
- Summary card of chosen preferences
- Primary CTA: `Start Exploring`

### Actions
- Persist onboarding complete flag
- Route to Home

---

## 4.6 Home Screen

### Purpose
Serve as the personalized dashboard.

### Layout Blocks
1. App bar with greeting and add button
2. Hero summary card
3. Quick actions row
4. Upcoming match plans section
5. Favorite teams section
6. Recent journal entries section
7. Tournament highlights section

### Components
- Greeting: `Hello, Alex`
- Summary stats chips
- Quick action buttons:
  - Add Match
  - Add Team
  - Add Journal Entry
  - Add Prediction
- Horizontal cards for upcoming matches
- Team pills / mini cards
- Journal preview cards

### States
- **Populated:** show all sections
- **Empty:** illustration + message + CTA
- **Error:** storage read error card

### Actions
- Tap quick actions → relevant editor
- Tap section header → full list
- Tap card → detail screen

---

## 4.7 Teams List Screen

### Purpose
Manage favorite teams.

### Layout Blocks
- Search field
- Sport filter chips
- List of team cards
- FAB: `Add Team`

### Team Card Fields
- Team name
- Sport
- Color tag
- Favorite badge
- Short note

### Empty State
- Illustration
- Text: `No teams yet`
- CTA: `Add your first team`

### Actions
- Add team
- Edit existing team
- Delete team with confirmation
- Toggle favorite

---

## 4.8 Add/Edit Team Screen

### Purpose
Create or edit a team entry.

### Form Fields
- Team name (required)
- Sport (required dropdown)
- Color tag (preset choice)
- Rival / derby note (optional)
- Country / league text (optional)
- Favorite toggle
- Notes (optional multiline)

### Validation
- Team name 2–40 chars
- Sport required
- Notes max 300 chars

### Buttons
- `Save`
- `Delete` (edit mode only)

### Success Behavior
- Save to local storage
- Pop screen and refresh list

---

## 4.9 Planner Screen

### Purpose
Track planned and completed match-day items.

### Layout Blocks
- Segment control: Planned / Watched / Missed / All
- Month selector chip row
- Match cards list
- FAB: `Add Match`

### Match Card Fields
- Home side vs away side
- Date/time
- Tournament
- Watch method or location
- Status badge
- Reminder icon if enabled

### Empty State
- `No match plans yet`

### Actions
- Tap card → Match Details
- Swipe actions:
  - Mark Watched
  - Mark Missed
  - Delete

---

## 4.10 Add/Edit Match Screen

### Purpose
Create manual match plans.

### Form Fields
- Team / main side (required)
- Opponent (required)
- Sport (required)
- Tournament name (optional)
- Date (required)
- Time (required)
- Location / watch method (optional)
- Reminder toggle
- Reminder offset (15m / 1h / 3h / 1d)
- Notes (optional)

### Validation
- Team and opponent cannot be identical
- Date/time cannot be empty
- Notes max 500 chars

### Actions
- Save match
- Schedule/cancel local reminder if enabled

---

## 4.11 Match Details Screen

### Purpose
Show full details for a planned or completed match.

### Layout Blocks
- Header with matchup
- Metadata rows
- Notes section
- Linked prediction section
- Linked journal entries section
- Bottom action bar

### Actions
- Edit match
- Add prediction
- Add journal entry
- Mark as Watched / Missed

---

## 4.12 Predictions Screen

### Purpose
Review personal predictions.

### Layout Blocks
- Filter chips: Pending / Correct / Incorrect / All
- Prediction cards list
- CTA to add prediction from a match

### Prediction Card Fields
- Match title
- Predicted winner
- Confidence level
- Result badge
- Reason preview

### Empty State
- `No predictions yet`

---

## 4.13 Add/Edit Prediction Screen

### Purpose
Save personal match predictions.

### Form Fields
- Related match (required)
- Predicted winner (required)
- Confidence slider (1–5)
- Reasoning text (optional)
- Result status selector: Pending / Correct / Incorrect

### Validation
- Match required
- Winner must match one of the sides
- Reason max 250 chars

---

## 4.14 Journal Screen

### Purpose
Store fan memories and reactions.

### Layout Blocks
- Filter chips by mood/team/sport
- Reverse chronological list
- FAB: `Add Entry`

### Journal Card Fields
- Title
- Date
- Linked team
- Mood chip
- Preview text

### Empty State
- `Your fan journal is empty`

---

## 4.15 Add/Edit Journal Entry Screen

### Purpose
Create a post-match or tournament note.

### Form Fields
- Title (required)
- Date (default today)
- Linked team (optional)
- Linked match (optional)
- Mood: Excited / Proud / Nervous / Disappointed / Neutral
- Entry text (required)

### Validation
- Title 2–60 chars
- Entry body 10–1000 chars

---

## 4.16 Tournament Collections Screen

### Purpose
Store tournaments and competitions the user cares about.

### Layout Blocks
- Pinned tournaments block
- All tournaments list
- Sort menu: Newest / Name / Season
- FAB: `Add Tournament`

### Tournament Card Fields
- Tournament name
- Sport
- Season/year
- Favorite participants count
- Pinned badge

---

## 4.17 Add/Edit Tournament Screen

### Purpose
Create or edit a tournament collection.

### Form Fields
- Tournament name (required)
- Sport (required)
- Season/year (required)
- Favorite participants (optional text list)
- Notes (optional)
- Pin toggle

### Validation
- Name 2–50 chars
- Season/year 2–20 chars

---

## 4.18 Stats Summary Screen

### Purpose
Provide lightweight offline insights.

### Metrics
- Total teams
- Planned matches
- Watched matches
- Prediction accuracy
- Journal entries
- Active tournaments

### Visualization
- Use simple cards and progress bars only
- No complex chart dependency required

---

## 4.19 Settings Screen

### Purpose
App preferences and data management.

### Layout Blocks
- Profile section
- Appearance section
- Notifications section
- Data management section
- About section

### Options
- Edit nickname
- Theme mode: System / Light / Dark
- Toggle reminder defaults
- Export data
- Import data
- Reset onboarding
- Clear all data

### Confirmation Required
- Import overwrite
- Clear all data
- Reset onboarding

---

## 5. Data Model

## 5.1 UserProfile
```json
{
  "nickname": "Alex",
  "favoriteSports": ["Football", "Basketball"],
  "defaultRemindersEnabled": true,
  "themeMode": "system"
}
```

### Fields
- `nickname: String`
- `favoriteSports: List<String>`
- `defaultRemindersEnabled: bool`
- `themeMode: String` (`system|light|dark`)

---

## 5.2 TeamItem
```json
{
  "id": "team_001",
  "name": "City Hawks",
  "sport": "Basketball",
  "colorTag": "blue",
  "league": "Local League",
  "rivalNote": "Big derby rival: North Storm",
  "isFavorite": true,
  "notes": "Strong home support"
}
```

### Fields
- `id: String`
- `name: String`
- `sport: String`
- `colorTag: String`
- `league: String?`
- `rivalNote: String?`
- `isFavorite: bool`
- `notes: String?`

---

## 5.3 MatchPlan
```json
{
  "id": "match_001",
  "teamName": "City Hawks",
  "opponentName": "River Lions",
  "sport": "Basketball",
  "tournament": "Spring Cup",
  "dateTimeIso": "2026-04-11T19:30:00",
  "watchMethod": "Home TV",
  "status": "planned",
  "reminderEnabled": true,
  "reminderOffsetMinutes": 60,
  "notes": "Watch with friends"
}
```

### Fields
- `id: String`
- `teamName: String`
- `opponentName: String`
- `sport: String`
- `tournament: String?`
- `dateTimeIso: String`
- `watchMethod: String?`
- `status: String` (`planned|watched|missed`)
- `reminderEnabled: bool`
- `reminderOffsetMinutes: int`
- `notes: String?`

---

## 5.4 PredictionItem
```json
{
  "id": "pred_001",
  "matchId": "match_001",
  "predictedWinner": "City Hawks",
  "confidence": 4,
  "reason": "Stronger recent form",
  "resultStatus": "pending"
}
```

### Fields
- `id: String`
- `matchId: String`
- `predictedWinner: String`
- `confidence: int` (1–5)
- `reason: String?`
- `resultStatus: String` (`pending|correct|incorrect`)

---

## 5.5 JournalEntry
```json
{
  "id": "journal_001",
  "title": "Huge comeback match",
  "dateIso": "2026-04-11",
  "teamId": "team_001",
  "matchId": "match_001",
  "mood": "Excited",
  "body": "Amazing second half and incredible atmosphere."
}
```

### Fields
- `id: String`
- `title: String`
- `dateIso: String`
- `teamId: String?`
- `matchId: String?`
- `mood: String`
- `body: String`

---

## 5.6 TournamentItem
```json
{
  "id": "tour_001",
  "name": "Champions Weekend",
  "sport": "Football",
  "seasonLabel": "2026",
  "favoriteParticipants": ["North FC", "Blue Harbor"],
  "isPinned": true,
  "notes": "Priority tournament for this season"
}
```

### Fields
- `id: String`
- `name: String`
- `sport: String`
- `seasonLabel: String`
- `favoriteParticipants: List<String>`
- `isPinned: bool`
- `notes: String?`

---

## 6. Local Persistence

## Storage Approach
Use **SharedPreferences** for lightweight app settings and **JSON-encoded model lists** for app content. This keeps implementation simple and review-safe for a placeholder app.

### Recommended Packages
- `shared_preferences`
- `flutter_local_notifications`
- `uuid`
- `intl`

### UserDefaults / SharedPreferences Keys List
- `onboarding_completed`
- `profile_data_json`
- `teams_list_json`
- `matches_list_json`
- `predictions_list_json`
- `journal_list_json`
- `tournaments_list_json`
- `theme_mode`
- `last_export_date`

### Encoding/Decoding Approach
- Each model implements `toJson()` / `fromJson()`
- Collections are stored as `List<Map<String, dynamic>>` encoded to JSON string
- Wrap storage access in a simple repository/service layer
- Use safe decode fallback:
  - invalid JSON → return empty list or default object
  - log silently in debug mode

### Basic Migration Strategy
Include a small schema version key:
- `storage_schema_version = 1`

Future migrations:
1. Read stored version
2. If version missing, treat as version 1
3. If version outdated, run map transformations before decode
4. Save upgraded payload and new version

Example future-safe migration cases:
- adding new field defaults
- converting reminder enum values
- splitting `teamName` into `teamId`

---

## 7. Onboarding Flow

### Total Screens
4 screens

### Collected Data
1. Favorite sports
2. Nickname
3. Default reminder preference
4. Optional starter team name

### Stored Keys
- `onboarding_completed`
- `profile_data_json`

### Completion Logic
- On final step tap `Start Exploring`
- Save profile defaults
- Save onboarding flag
- Route to main shell

### Re-entry Logic
- Settings includes `Reset Onboarding`
- Reset only clears onboarding state and profile preference setup if user confirms

---

## 8. UI Kit / Design Tokens Usage

## Visual Direction
Neutral sports-inspired design with no direct club, league, casino, or betting associations.

### AppColors
```dart
class AppColors {
  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFEEF1F5);
  static const primary = Color(0xFF1E6BFF);
  static const primaryDark = Color(0xFF1449B5);
  static const accent = Color(0xFFFF7A00);
  static const success = Color(0xFF18A957);
  static const warning = Color(0xFFF4A100);
  static const error = Color(0xFFD64545);
  static const textPrimary = Color(0xFF101828);
  static const textSecondary = Color(0xFF667085);
  static const border = Color(0xFFD9E0EA);
  static const darkBackground = Color(0xFF0F1720);
  static const darkSurface = Color(0xFF18212B);
}
```

### AppFonts
Use system-friendly typography:
- Display / headings: `Inter` or platform default bold
- Body: `Inter` or platform default regular
- Numbers/stat labels: same family, semi-bold

Suggested type scale:
- Display: 28
- H1: 24
- H2: 20
- H3: 18
- Body: 14 / 16
- Caption: 12

### AppSpacing
```dart
class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
}
```

### AppCorners
```dart
class AppCorners {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
}
```

### AppShadows
Use subtle, neutral shadows:
- Card shadow: low blur, low opacity
- No neon effects
- Avoid glossy gradients

### Component Style Notes
- Rounded cards with soft borders
- Filled primary buttons with strong contrast
- Filter chips with clear selected state
- FAB only on content creation screens
- Lists use clear spacing and simple separators
- Support both Light and Dark mode

---

## 9. Accessibility Checklist

- Support Dynamic Text scaling through Flutter text scaling
- Minimum touch target: 44x44 pt equivalent
- Semantic labels for icon-only buttons
- High contrast in both Light and Dark themes
- Do not use color alone to communicate status; add labels/icons
- Form errors must include text, not only border color
- Respect platform reduced motion settings where applicable
- Screen-reader friendly navigation order
- Sufficient spacing for tappable chips and cards
- Date/time pickers must use platform-native components where possible

---

## 10. App Store / Play Store Compliance Notes

### Safety Positioning
- No gambling mechanics
- No real-money rewards
- No betting odds or payouts
- No misleading references to official leagues or clubs
- User-entered content only

### Privacy
- No account required
- No external analytics required for MVP
- No backend
- Local-only user data

### Permissions
- **Notifications:** only if user enables local reminders
- No location required
- No camera required
- No contacts required
- No microphone required

### Disclaimers
Include a simple note in Settings/About:
`FanArena is a personal offline organizer for sports fans. It does not provide live scores, ticket sales, or official competition data.`

### Review Safety
- Include useful sample empty states and demo content option if desired
- Avoid blank screens at first launch
- Ensure all tabs have purposeful content and clear CTAs
- Ensure export/import is explained clearly

---

## 11. Acceptance Criteria Per Core Feature

### Onboarding
- User sees onboarding only on first launch
- User can complete onboarding in under 1 minute
- Preferences persist after relaunch

### Teams
- User can add, edit, favorite, search, and delete teams
- List refreshes immediately after changes
- Empty state appears when list is empty

### Planner
- User can add a match with required fields
- Match can be marked as watched or missed
- Reminder is scheduled only when enabled

### Predictions
- User can attach a prediction to a saved match
- Prediction stores confidence and result status
- Prediction list can be filtered by status

### Journal
- User can create, edit, and delete journal entries
- Entries appear in reverse chronological order
- Linked team/match info displays correctly when present

### Tournaments
- User can create tournament collections and pin them
- Pinned items appear first in the list

### Settings / Data
- User can switch theme mode and see it persist
- User can export all local data as JSON
- User can import valid JSON and restore data
- User can clear all data after confirmation

### Overall Quality
- App works fully offline after install
- Light and Dark mode both look polished
- No dead-end screens
- No brand-specific or restricted sports-book visual language
