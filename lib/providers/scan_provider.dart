import 'dart:async';
import 'package:flutter/foundation.dart';

enum ScanPhase { row, column }

/// Manages the Switch Scan Mode accessibility feature.
///
/// The scan cycles through **rows** first. When any tap is received during the
/// row phase, the currently-highlighted row is selected and scanning enters the
/// **column phase**, cycling through the individual items in that row. A second
/// tap executes the highlighted item's action.
///
/// Row 0 is always the "top controls" row (speak, clear, back, scan toggle).
/// Rows 1..N are the vocabulary/group-tile grid rows.
class ScanProvider with ChangeNotifier {
  bool _isScanModeEnabled = false;

  /// Duration each item is highlighted before automatically advancing (seconds).
  /// Fractional values are supported (e.g. 1.5 s).
  double scanIntervalSeconds = 3.0;

  /// Update the scan interval and restart the current timer immediately.
  void setScanInterval(double seconds) {
    scanIntervalSeconds = seconds.clamp(0.1, 10.0);
    // Restart timer at the new rate if scanning is currently active.
    if (_isScanModeEnabled && _rowColumnCounts.isNotEmpty) {
      _scheduleAdvance();
    }
    notifyListeners();
  }


  ScanPhase _phase = ScanPhase.row;
  int _highlightedRow = -1;    // -1 = nothing highlighted
  int _highlightedColumn = -1; // -1 = nothing highlighted
  int _selectedRow = -1;       // the row that was tapped during row phase

  /// Number of interactive columns per row. Index 0 = top-controls row.
  List<int> _rowColumnCounts = const [];

  Timer? _timer;

  // ─── Getters ─────────────────────────────────────────────────────────────

  bool get isScanModeEnabled => _isScanModeEnabled;
  ScanPhase get phase => _phase;
  int get highlightedRow => _highlightedRow;
  int get highlightedColumn => _highlightedColumn;
  int get selectedRow => _selectedRow;
  int get numRows => _rowColumnCounts.length;

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Toggle scan mode on/off. Stops all scanning when turned off.
  void toggleScanMode() {
    _isScanModeEnabled = !_isScanModeEnabled;
    if (_isScanModeEnabled) {
      if (_rowColumnCounts.isNotEmpty) _startRowScan();
    } else {
      _doStopScan();
    }
    notifyListeners();
  }

  /// Configure the scannable row layout for the current screen.
  ///
  /// [rowColumnCounts[i]] is the number of interactive columns in row i.
  /// Rows with 0 columns are ignored. Restarts scanning only when the
  /// configuration actually changes, preventing infinite rebuild loops.
  void configureScreen(List<int> rowColumnCounts) {
    final filtered = rowColumnCounts.where((c) => c > 0).toList();

    // Only restart if the configuration changed
    bool changed = filtered.length != _rowColumnCounts.length;
    if (!changed) {
      for (int i = 0; i < filtered.length; i++) {
        if (filtered[i] != _rowColumnCounts[i]) {
          changed = true;
          break;
        }
      }
    }

    _rowColumnCounts = List.unmodifiable(filtered);

    if (_isScanModeEnabled && changed) {
      _startRowScan();
      notifyListeners();
    }
  }

  /// Called when the user taps anywhere on the screen while scan mode is on.
  ///
  /// **Row phase**: transitions to column phase; returns `null`.
  /// **Column phase**: returns `(selectedRow, selectedColumn)` so the caller
  /// can execute the action. The caller must then call [restartRowScan].
  (int, int)? onTap() {
    if (!_isScanModeEnabled || _rowColumnCounts.isEmpty) return null;
    _cancelTimer();

    if (_phase == ScanPhase.row) {
      if (_highlightedRow < 0 || _highlightedRow >= _rowColumnCounts.length) {
        _startRowScan();
        return null;
      }
      final numCols = _rowColumnCounts[_highlightedRow];
      if (numCols <= 0) {
        _advance(); // skip empty rows
        return null;
      }
      _selectedRow = _highlightedRow;
      _phase = ScanPhase.column;
      _highlightedRow = -1;
      _highlightedColumn = 0;
      notifyListeners();
      _scheduleAdvance();
      return null; // entering column phase, no action yet
    } else {
      // Column phase — return the selection to the caller
      final row = _selectedRow;
      final col = _highlightedColumn;
      _highlightedColumn = -1;
      _highlightedRow = -1;
      notifyListeners();
      return (row, col);
    }
  }

  /// Restart row scanning from the beginning. Call after an action executes.
  void restartRowScan() {
    if (_isScanModeEnabled && _rowColumnCounts.isNotEmpty) {
      _startRowScan();
    }
  }

  // ─── Internal ─────────────────────────────────────────────────────────────

  void _startRowScan() {
    _cancelTimer();
    _phase = ScanPhase.row;
    _selectedRow = -1;
    _highlightedColumn = -1;
    _highlightedRow = _rowColumnCounts.isNotEmpty ? 0 : -1;
    if (_rowColumnCounts.isNotEmpty) _scheduleAdvance();
  }

  void _scheduleAdvance() {
    _cancelTimer();
    _timer = Timer(Duration(milliseconds: (scanIntervalSeconds * 1000).round()), _advance);
  }

  void _advance() {
    if (!_isScanModeEnabled || _rowColumnCounts.isEmpty) return;

    if (_phase == ScanPhase.row) {
      _highlightedRow = (_highlightedRow + 1) % _rowColumnCounts.length;
    } else {
      final numCols = (_selectedRow >= 0 && _selectedRow < _rowColumnCounts.length)
          ? _rowColumnCounts[_selectedRow]
          : 0;
      if (numCols > 0) {
        _highlightedColumn = (_highlightedColumn + 1) % numCols;
      }
    }
    notifyListeners();
    _scheduleAdvance();
  }

  void _doStopScan() {
    _cancelTimer();
    _phase = ScanPhase.row;
    _highlightedRow = -1;
    _highlightedColumn = -1;
    _selectedRow = -1;
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }
}
