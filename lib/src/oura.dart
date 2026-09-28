// Copyright (c) 2025, OpenStrap contributors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be found
// in the LICENSE file.

/// The Oura Ring wire protocol, against real captured bytes.
///
/// PROVENANCE, stated up front because this file's ground rules demand it:
/// every decoder here is checked against bytes a real ring emitted, with the
/// one labelled exception, and nothing here was copied from anyone's decoder.
/// The framing, the envelope and the debug_data sub-records are from a
/// 10,208-record capture; the hypnogram layout is documented from real
/// captures by the open_oura project, whose Rust decoder this ports, code
/// for code, for the sleep phases alone.
///
/// WHAT THIS FILE IS NOT: it is not a session driver. Pairing, encryption,
/// draining, retries and cursor management live in the app that drives this
/// wire; this file only turns bytes into numbers it can justify, and refuses
/// (returns null) when it cannot.

import 'dart:typed_data';

/// The first event tag the ring uses for history records. Anything below this
/// is a command response, not a history event.
const int kOuraFirstEventTag = 0x40;

/// Wall-clock the ring recorded when the host last set its RTC. The ONLY event
/// that pairs a Unix second with an envelope decisecond, which makes it the one
/// honest anchor between the two clocks.
const int kOuraEvtTimeSync = 0x42;

/// An array of skin-temperature probes.
const int kOuraEvtTemp = 0x46;

/// A single skin-temperature reading.
const int kOuraEvtTempPeriod = 0x69;

/// The sleep-stage hypnogram, in three generations of carrier:
/// `sleep_phase_information` (0x4b), `sleep_phase_details` (0x4e) and the
/// paged `sleep_phase_data` (0x5a).
const int kOuraEvtSleepPhaseInformation = 0x4b;
const int kOuraEvtSleepPhaseDetails = 0x4e;
const int kOuraEvtSleepPhaseData = 0x5a;

/// Firmware diagnostics. Subtype-multiplexed; see [decodeDebugData].
const int kOuraEvtDebugData = 0x61;

/// The frame that terminates one history batch.
const int kOuraTagBatchSummary = 0x11;

/// One history event, as the ring emitted it: its tag, its own clock in
/// deciseconds, and the body after the 4-byte envelope timestamp.
class OuraEvent {
  final int tag;

  /// The ring's own clock, in units of 100 ms. NOT Unix time — see the header.
  final int tsDs;

  final Uint8List body;
  const OuraEvent(this.tag, this.tsDs, this.body);
}

PLACEHOLDER_DECODERS
