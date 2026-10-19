# 🪂 Vanguard Royale 3D (iOS)

[![Build Vanguard Royale 3D IPA](https://github.com/flobure2008-ui/VanguardRoyale/actions/workflows/build-ipa.yml/badge.svg)](https://github.com/flobure2008-ui/VanguardRoyale/actions)
[![Platform](https://img.shields.io/badge/Platform-iOS%2015.0%2B-blue.svg)](https://apple.com)
[![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange.svg)](https://swift.org)
[![Engine](https://img.shields.io/badge/Engine-SceneKit%203D%20%2B%20Metal-purple.svg)](https://developer.apple.com)

> **Un jeu Battle Royale 3D complet et réaliste pour iPhone et iPad inspiré de PUBG et Fortnite : largage en parachute, île ouverte en 3D avec villes et bunkers, cercle de tempête rétrécissant, arsenal militaire, bots IA en combat actif, construction tactique et pipeline GitHub Actions pour exporter automatiquement le jeu en fichier `.ipa` !**

---

## 🎮 Fonctionnalités du Battle Royale 3D

1. **Largage Aérien & Parachute 3D** :
   - Vous commencez à 100 mètres d'altitude au-dessus d'une île 3D géante (`400x400m`).
   - Pilotez votre descente en parachute / deltaplane pour atterrir sur votre zone de largage préférée (*Pochinki Outpost*, *Military Base*, *Docklands*, *Sniper Ridge*).
2. **Vue Troisième Personne (TPS) & Viseur ADS** :
   - Caméra à l'épaule dynamique avec lissage et recul d'arme.
   - Bouton **ADS (Aim Down Sights)** : Zoom optique de précision pour les tirs longue distance.
3. **Cercle de Tempête Électrique Rétrécissant** :
   - Cylindre d'énergie géant en 3D qui rétrécit en 5 phases successives.
   - Si vous restez en dehors de la zone sûre, l'écran vire au violet et vous subissez des dégâts continus !
4. **Arsenal Militaire Réaliste & Loot au Sol** :
   - **M4A1 Assault Rifle** : Fusil automatique polyvalent avec faisceau bleu Rare.
   - **AKM Heavy Rifle** : Gros dégâts de pénétration avec faisceau violet Epic.
   - **AWM Sniper Rifle** : Fusil de précision mortel (one-shot headshot) avec faisceau doré Legendary.
   - **Pump Shotgun** : Dévastateur au corps-à-corps dans les bâtiments.
   - **Kits Médicaux & Potions de Bouclier** : Régénérez vos barres de Santé (100 HP) et d'Armure (100 Shield).
5. **Construction de Couverture Tactique (Style Fortnite)** :
   - Récoltez des matériaux en bois et touchez le bouton **BUILD** pour ériger instantanément une palissade renforcée en 3D devant vous pour vous protéger des tirs de snipers ennemis !
6. **25 Combattants IA en Temps Réel** :
   - Des soldats ennemis parcourent l'île, collectent des armes, s'affrontent entre eux et ouvrent le feu lorsqu'ils vous repèrent.
   - Killfeed dynamique affichant les éliminations en direct sur l'île.
   - Compteur de survivants : Éliminez le dernier adversaire pour déclencher le légendaire **#1 VICTORY ROYALE / WINNER WINNER CHICKEN DINNER** !
7. **Largages Aériens (Airdrops)** :
   - Des caisses de ravitaillement tombent du ciel en parachute avec fumée de détresse rouge contenant de l'équipement légendaire.

---

## 🚀 Compilation & Conversion Automatique en `.ipa` sur GitHub

Le projet dispose d'un workflow GitHub Actions optimisé (`.github/workflows/build-ipa.yml`) qui s'exécute sur les machines virtuelles macOS d'Apple (`macos-14` avec Apple Silicon).

### Comment créer le dépôt et obtenir votre IPA :

1. Créez un nouveau dépôt sur GitHub nommé `VanguardRoyale`.
2. Poussez le projet :
   ```bash
   git init
   git add .
   git commit -m "feat: complete Vanguard Royale 3D Battle Royale iOS game"
   git branch -M main
   git remote add origin https://github.com/VOTRE_PSEUDO/VanguardRoyale.git
   git push -u origin main --tags
   ```
3. GitHub Actions compile automatiquement le projet et génère le fichier `VanguardRoyale.ipa` dans l'onglet **Actions** et dans les **Releases** de votre dépôt !

---

## 📲 Comment installer l'IPA sur iPhone / iPad

- **AltStore** : Téléchargez le `.ipa` depuis Safari, ouvrez AltStore > My Apps > `+` > sélectionnez `VanguardRoyale.ipa`.
- **Sideloadly** : Glissez-déposez `VanguardRoyale.ipa` sur PC/Mac relié à votre iPhone.
- **TrollStore / Scarlet** : Ouvrez directement le fichier `.ipa` pour l'installer.

---

## 📂 Architecture du Projet

```
VanguardRoyale-iOS/
├── .github/workflows/build-ipa.yml      # CI/CD GitHub Actions pour compiler l'IPA
├── VanguardRoyale.xcodeproj/            # Projet Xcode 15/16 SceneKit 3D + Metal
├── VanguardRoyale/
│   ├── App/
│   │   ├── VanguardRoyaleApp.swift      # Point d'entrée SwiftUI paysage
│   │   └── Info.plist                   # Configuration orientation & ProMotion 120Hz
│   ├── Engine3D/
│   │   ├── Game3DViewController.swift   # Contrôleur d'affichage SCNView 120 FPS
│   │   ├── BattleRoyaleScene.swift      # Scène 3D principale (Soleil, terrain, bots, raycast)
│   │   ├── TerrainBuilder.swift         # Générateur de l'île (Océan, villes, maisons, tours)
│   │   ├── PlayerCharacterNode.swift    # Soldat 3D, caméra TPS épaule, parachute
│   │   ├── BotAINode.swift              # IA des soldats ennemis, tirs et ragdoll
│   │   ├── WeaponSystem.swift           # Balistique, M4A1, AWM, AKM, Shotgun, recul
│   │   ├── StormSystem.swift            # Cylindre 3D de la tempête et zone sûre
│   │   ├── LootItemNode.swift           # Caisses et armes au sol avec faisceau de rareté
│   │   ├── BuildingSystem.swift         # Pose instantanée de murs tactiques en 3D
│   │   └── SoundFXEngine.swift          # Synthétiseur de coups de feu et bruitages 3D
│   ├── State/
│   │   ├── BattleState.swift            # Gestionnaire de PV, bouclier, survivants, storm
│   │   └── KillfeedManager.swift        # Journal des éliminations en temps réel
│   ├── UI/
│   │   ├── HUD3DView.swift              # Réticule, hitmarker, joystick virtuel, boutons d'action
│   │   ├── VictoryRoyaleView.swift      # Écran de victoire #1 Victory Royale
│   │   └── DefeatView.swift             # Écran d'élimination avec rang
│   └── Assets.xcassets/
│       └── AppIcon.appiconset/          # Icône militaire 1024x1024
└── scripts/
    └── generate_pbxproj.py              # Script de génération du projet Xcode
```

---

*Développé pour offrir une expérience Battle Royale 3D native, fluide et viscérale sur iOS.*
