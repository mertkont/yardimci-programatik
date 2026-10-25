import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_theme.dart';
import '../utils/calc.dart';

Color pacingColor(BuildContext context, PacingState s) {
  final p = context.palette;
  switch (s) {
    case PacingState.underpacing:
      return p.warn;
    case PacingState.overpacing:
      return p.danger;
    case PacingState.onTrack:
      return p.success;
    case PacingState.notStarted:
      return p.accent;
    case PacingState.ended:
      return p.neutral;
  }
}

String pacingLabel(L10n l, PacingState s) {
  switch (s) {
    case PacingState.underpacing:
      return l.s('Underpacing', 'Underpacing');
    case PacingState.overpacing:
      return l.s('Overpacing', 'Overpacing');
    case PacingState.onTrack:
      return l.s('On track', 'Yolunda');
    case PacingState.notStarted:
      return l.s('Not started', 'Başlamadı');
    case PacingState.ended:
      return l.s('Ended', 'Bitti');
  }
}

Color statusColor(BuildContext context, String status) {
  final p = context.palette;
  switch (status) {
    case 'active':
      return p.success;
    case 'paused':
      return p.warn;
    case 'completed':
      return p.neutral;
    case 'draft':
      return p.accent;
  }
  return p.muted;
}

String statusLabel(L10n l, String status) {
  switch (status) {
    case 'active':
      return l.s('Active', 'Aktif');
    case 'paused':
      return l.s('Paused', 'Duraklatıldı');
    case 'completed':
      return l.s('Ended', 'Bitti');
    case 'draft':
      return l.s('Draft', 'Taslak');
  }
  return status;
}
