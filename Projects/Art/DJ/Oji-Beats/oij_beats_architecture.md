High-Level Oji Beats Architecture

Event-driven core: adapters ingest packets/PCM → normalized SessionTimeline (timebase + phase + tempo) → event bus → UI/renderers.
Separate services: Discovery (find/link to sources), SyncEngine (phase/BPM alignment), WaveformService (fetch/precompute/caches), MetadataService (artist/title/cues), Bridge (Ableton Link/MIDI/OSC), Persistence (local cache + session restore).
Stateless UI consumers: subscribe to SessionTimeline and WaveformFeed for rendering and controls, never touching adapters directly.
Low-latency path: adapters write to lock-free ring buffers; timeline updates on high-priority timer; renderers pull read-only snapshots.
Beat Link Trigger Reference Summary

architecture_overview: Clojure app; Swing UI via Seesaw; relies on Beat Link singletons (DeviceFinder, VirtualCdj, BeatFinder, MetadataFinder, BeatGridFinder, TimeFinder, WaveformFinder, SignatureFinder, CrateDigger) to join Pioneer Pro DJ Link; Carabiner/Ableton Link bridge via beat-carabiner; overlay HTTP server for OBS templates/PNGs.
audio_and_timing_logic: BeatFinder dispatches BeatListener events to triggers; DeviceUpdateListener feeds status per player; Metronome-based MIDI clock thread sends 24 ppqn based on CdjStatus.getEffectiveTempo (or override) and pitch; Carabiner bridge locks/aligns Ableton Link tempo/phase (beat-carabiner/lock-tempo, beat-at-time, manual/passive/full sync modes); TimeFinder/BeatGridFinder supply position + beat grid for alignment and overlays.
data_structures: Trigger user-data map holds :value (UI settings), :expressions/:expression-fns, :playing, :on-air, :tripped, :status (latest CdjStatus), :locals (atom), :clock (thread + Metronome + running flag), :last-match [score device]; global expression-globals atom for cross-trigger state. Show tracks stored in a ZIP-backed map with :signature, :metadata, :beat-grid, :preview (WaveformPreview), :detail (WaveformDetail), :cue-list, UI handles, and contents for MIDI/expressions.
ui_components: Trigger window rows with player selection (Any/Master/explicit), message type (Note/CC/Clock/Link/Custom), enable modes, gear menu for expressions; Player Status window with live metadata and WaveformDetailComponent; Show window with track list, preview waveforms, cue editor with zoomable WaveformDetailComponent, lane overlays for cues; Overlay HTTP server (/params.json, /wave-preview/:player, /wave-detail/:player) renders PNGs and JSON for OBS templates.
configuration_and_integrations: Preferences via EDN (Beat Link Trigger.cfg); supports offline mode and reconnection flow; optional metadata caches; Ableton Link via Carabiner socket (port, latency, sync mode, bar alignment); MIDI via overtone.midi/CoreMIDI.
reusable_patterns_for_oji_beats: Listener-based ingestion + cached state atoms to keep UI off hot paths; singletons for network resources; background threads for timing-sensitive work with EDT handoff for UI; expression pipeline for user-defined hooks; PNG-serving overlay with templated JSON payloads for remote UIs; multi-resolution waveform components (preview/detail) plus cue overlays.
Proposed Oji Beats Connector Layer

Concept diagram:
[ProDJLink Adapter] [LocalFile/DAW Adapter] [LiveAudio Analyzer] [AbletonLink Bridge]
            \              |                      |                    /
             \             |                      |                   /
              ----> [Session Sync Engine & Timeline] <-> [Waveform/Metadata Cache]
                             |            |
                         [Event Bus]   [Persistence]
                             |
                        [UI / APIs]
Modules:
ConnectorHost: lifecycle, config, dependency injection.
SourceRegistry: manages adapters (ProDjLinkAdapter using Beat Link/VirtualCdj/BeatFinder; AbletonLinkAdapter via Carabiner; FileAdapter for local stems; LiveInputAdapter for capture + onset/beat detection).
SessionTimeline: canonical clock (tempo, phase, beat index, bar alignment, latency estimates) with high-priority scheduler.
SyncEngine: computes drift between sources, applies nudges (Ableton Link tempo/phase, virtual CDJ status packets when allowed), exposes SyncState.
WaveformService: async retrieval + multires caches (preview/detail), rolling buffers for live capture, disk cache for re-use.
MetadataService: track IDs, titles, cue grids, signatures; can ingest Rekordbox via CrateDigger-equivalent.
EventBus: typed streams (BeatEvent, TransportEvent, WaveformChunk, TrackLoaded, SyncStateChanged, Error).
Bridge: MIDI clock/notes, OSC, future Link/MIDI/OSC sync; handles latency compensation.
Persistence: cache directory for waveforms/metadata/signatures and session restore.
Data flow:
Adapters emit decoded SourceEvent (status/beat/position/trackInfo/waveformChunk) → SourceRegistry normalizes → SessionTimeline updates shared timebase → EventBus fan-out to UI and WaveformService.
SyncEngine subscribes to BeatEvent + TransportEvent to compute phase error and drive AbletonLinkBridge / ProDJLink tempo nudges.
WaveformService serves WaveformStream objects (preview/detail/live) to UI with chunking and backpressure.
Example Swift-style interfaces:
struct BeatEvent { let source: SourceID; let bpm: Double; let beatIndex: Int; let phase: Double; let at: TimeInterval }
struct TransportEvent { let source: SourceID; let playing: Bool; let onAir: Bool; let tempo: Double; let pitch: Double; let positionMs: Double }
struct WaveformChunk { let source: SourceID; let resolution: WaveformResolution; let startMs: Double; let durationMs: Double; let peaks: [Int16]; let beatMarkers: [Double]? }

protocol AudioSourceAdapter {
  var id: SourceID { get }
  func start() throws
  func stop()
  func subscribe(_ handler: @escaping (SourceEvent) -> Void)
  func requestWaveform(resolution: WaveformResolution, range: TimeRange?) async throws -> WaveformChunk
}

final class SessionTimeline {
  func current() -> TimelineSnapshot
  func add(event: TransportEvent)
  func add(beat: BeatEvent)
  func subscribe(_ handler: @escaping (TimelineSnapshot) -> Void)
}

final class SyncEngine {
  func lockTo(_ master: SourceID?, mode: SyncMode) // off | follow | lead | bidirectional
  func reportPhase(source: SourceID, phaseError: Double, at: TimeInterval)
}
Reuse/improve from Beat Link Trigger:
Keep Beat Link singletons for Pro DJ Link ingest; keep Carabiner for Ableton Link but hide behind AbletonLinkAdapter.
Preserve idea of separating preview/detail waveforms; add chunked streaming + disk cache with hashes (signature).
Adopt listener + cached state pattern to avoid EDT coupling; move timing-critical work to dedicated schedulers.
Replace per-trigger expressions with typed hooks/plugins for stability; optionally allow sandboxed scripting later.
Multi-Waveform UI Specification

Core concepts: WaveformModel (multi-res peaks, sampleRate, duration, beatGrid, cues, color theme, signature); WaveformViewState (zoomLevel, pixelsPerSecond/Beat, scrollOffset, lockToPlayhead); PlaybackCursor (timelineTime, phase, latencyComp); SyncBadge (synced, offsetMs, driftMs).
Buffering: maintain preview (downsampled whole track), detail (per-zoom chunked), and live ring buffer (N seconds PCM/peaks); prefetch next/previous chunks based on scroll; cache by signature+resolution.
Synchronization: anchor all rows to SessionTimeline playhead; compute globalOffsetPx = (sourceTime - timelineTime) * pixelsPerMs; apply drift correction smoothing (e.g., 10–20 ms hysteresis); align bar/beat grid from beatGrid; expose per-source phaseError.
Layout: horizontal rows with shared vertical beat grid; playhead fixed center; beats at pixel-perfect multiples of pixelsPerBeat to avoid jitter; allow per-row vertical scaling for energy; support stacked or side-by-side mini-rows for A/B comparison.
Zoom/scroll: wheel/pinch to change pixelsPerBeat and pixelsPerSecond; double-click to reset; follow mode auto-scrolls when playhead nears edge; drag to scrub (non-destructive seek request to connector).
Color-coding: per-source hue; downbeats emphasized; cues color-coded; shaded regions for loops; overlays for beat-phase error (e.g., small offset bar).
Visual signals: BPM change marker, sync lock icon, on-air badge, latency indicator; ghost waveform when data pending.
UI data consumption:
Position/beat updates: 30–60 fps TimelineSnapshot with playheadMs, bpm, phase, driftMs.
Beat events: discrete BeatEvent (bar/beat index) for flashing markers.
Waveform chunks: async WaveformChunk stream keyed by resolution and range; UI stitches into model.
Metadata: TrackDescriptor (title, artist, length, cues, signature).
Errors/disconnects: SourceStatusEvent (connecting, online, stalled, offline, error(reason)).
Requests to connector: requestWaveform(resolution, range), setZoom(resolution), setFollowMode(on/off), seek(source, positionMs), setMaster(source), nudge(source, deltaMs).
Implementation Notes & Next Steps

Stand up ProDjLinkAdapter by wrapping Beat Link DeviceFinder/VirtualCdj/BeatFinder/MetadataFinder/WaveformFinder with thread-safe fan-out; mirror Carabiner integration behind an adapter.
Define shared models (TimelineSnapshot, WaveformChunk, TrackDescriptor, SourceStatus) and the event bus API; prototype in Swift with Combine/AsyncSequence.
Build WaveformService with disk cache keyed by track signature; support both Rekordbox analysis files and live capture.
Prototype multi-waveform view using the new API, with shared timeline and per-row offsets; verify jitter/drift handling with synthetic beat streams before wiring real hardware.
