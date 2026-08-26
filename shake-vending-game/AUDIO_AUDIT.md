# AUDIO AUDIT — 2026-08-26

## Scope

This audit covers the persisted source audio architecture only. Roblox Studio/published-experience listening, asset-permission verification, loudness judgment and device speaker/headphone QA have **not** been performed in this environment.

## Implemented architecture

`src/ReplicatedStorage/Shared/SoundManifest.lua` now owns categorized sound definitions for:

- Machine: hum, button, click, rattle, tray clunk.
- UI: hover, click, confirm, error.
- Economy: coin, sell, purchase, unlock.
- Collection: collect, discovery, milestone.
- Engagement: Lucky Meter ready, mastery, gift.
- Rarity: Rare, Epic, Legendary, Mythic, Divine, Secret, Global.

The manifest also owns group mix targets and rare-reveal ducking parameters.

No new unverified audio IDs were added. The pass deliberately reuses only the three audio IDs already persisted in the project and changes gain/pitch/mix envelopes until additional Creator Store audio is manually verified. This is preferable to fabricating IDs.

## Runtime mixing

`AudioController.lua` creates dedicated `SoundGroup`s:

- `ShakeVM_SFX`
- `ShakeVM_UI`
- `ShakeVM_Ambient`
- `ShakeVM_Music`
- `ShakeVM_RareReveal`

It now provides:

- category/name lookup through `PlayCategory`;
- manifest-defined cooldowns;
- per-definition concurrent-instance caps;
- positional rolloff for machine sounds;
- cleaned-up machine hum lifecycle;
- quiet automatic hover/click feedback for current and dynamically-added GUI buttons;
- rare-reveal ducking of music, ambience and ordinary SFX with attack/hold/release restoration;
- persisted Music/SFX setting compatibility.

`ClientBootstrap.client.lua` binds `AudioController` to the built UI so later-created buttons inherit feedback without each panel adding bespoke listeners.

`MachineInteractionController.lua` retains positional rattle and clunk cues during the staged physical vending interaction.

`DropVisualController.lua` drives rarity sound through `PlayRarity`; rarity definitions marked `Duck=true` therefore invoke the mix duck automatically.

## Spam/performance protections

- UI hover and click sounds have short cooldowns.
- Repeated categories have `MaxInstances` caps.
- Active sound counts are released on `Ended` or destruction.
- One-shot sounds are cleaned with `Debris`.
- Machine hums are reused per machine and destroyed when the machine leaves the data model.
- GUI audio uses one descendant-added listener plus one pair of connections per button, and each button is marked `ShakeAudioBound` to prevent duplicate binding.

## Automated regression coverage

`tools/audio_quality_check.py` verifies:

- manifest category persistence;
- all five SoundGroups;
- cooldown/concurrency architecture;
- rare-reveal ducking;
- UI feedback wiring;
- positional vending audio markers;
- rarity audio wiring;
- absence of runtime untrusted asset loading in the audio manifest.

The production GitHub Actions workflow runs this audit alongside static, presentation, visual-quality and progression checks.

## Honest remaining audio blockers

1. Listen to every persisted audio ID in the published experience and confirm it is still permitted and appropriate.
2. Replace provisional reused donor sounds with individually-curated free Creator Store sounds only after title/creator/ID verification.
3. Tune group volumes on phone speakers, headphones and desktop speakers.
4. Verify that repeated mass-sell/rapid-shake flows do not sound fatiguing.
5. Verify Secret/Global reveals are recognizable by sound alone; the current architecture supports this but the small verified donor pool limits true timbral differentiation.
6. Curate and permission-test a light retail background music loop before claiming the master prompt's music requirement complete.

Until those Studio/published-experience checks are run, audio is source-architected but not release-certified.
