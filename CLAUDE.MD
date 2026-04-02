# Lern-Archiv · jkingma.sbw.media

## Project
Static multi-page learning site for Modul 290 (Datenbanken) at SBW Haus des Lernens, Romanshorn.
Target audience: Mediamatiker*innen (Swiss vocational training, BFS).
Language: German (de-CH).

## Structure
lern-archiv/
├── index.html          ← Landing page, 4 cards
├── db-theorie/         ← Flashcards, quiz, tuple checker
├── er-designer/        ← Visual ER diagram editor
├── sql-extra/          ← 10 SQL exercises
└── er-aufgaben/        ← 10 ER modelling tasks (Vue 3, 4 difficulty levels)

## Design System
- Background:  #f5f2eb (warm paper)
- Ink:         #1a1a18 / #6b6860 (dim) / #b8b4aa (faint)
- Rule:        #d9d5cc
- Accent 1:    #1a3a8f  (navy   – DB Theorie)
- Accent 2:    #8f3a1a  (terra  – ER Editor)
- Accent 3:    #1a6b3a  (forest – SQL Extra)
- Accent 4:    #5a1a8f  (violet – ER Aufgaben)
- Fonts:       DM Serif Display · DM Mono · DM Sans
- Texture:     SVG fractalNoise grain overlay, opacity 0.03
- Animations:  fadeUp (14px, staggered) + fadeIn on load

## Tech Stack
- Pure HTML/CSS/JS — no build step
- Vue 3 via CDN (unpkg) where needed
- localStorage for user progress
- No frameworks, no npm

## Conventions
- All new pages follow the same masthead/rule/footer pattern as index.html
- Back-link to ../ in every subpage
- Card counter in index.html must stay in sync (currently 04/04)
- Commit messages: type: short description (e.g. feat: add er-aufgaben page)