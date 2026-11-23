import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Komponen design system Tamajiwa. Dipakai ulang di semua layar.

/// Kartu putih dengan sudut besar dan garis halus.
class DsCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final double radius;

  const DsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
    this.radius = AppRadius.lg,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: color ?? cs.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Chip pil dengan ikon opsional (info kontak, filter, dsb).
class DsPill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback? onTap;
  final Color? background;

  const DsPill({
    super.key,
    required this.label,
    this.icon,
    this.selected = false,
    this.onTap,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = selected
        ? AppColors.lime
        : (background ?? cs.surfaceContainerLowest);
    final fg = selected ? AppColors.ink : cs.onSurface;
    return Material(
      color: bg,
      shape: StadiumBorder(
        side: BorderSide(color: selected ? AppColors.lime : cs.outlineVariant),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(
                      color: fg, fontWeight: FontWeight.w700, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lencana angka berwarna lime (seperti badge rating).
class DsBadge extends StatelessWidget {
  final String value;
  const DsBadge(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lime,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(value,
          style: const TextStyle(
              color: AppColors.ink, fontWeight: FontWeight.w800, fontSize: 13)),
    );
  }
}

enum DsStatus { draft, submitted, revision, approved }

DsStatus dsStatusFrom(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'approved':
    case 'disetujui':
      return DsStatus.approved;
    case 'revised':
    case 'revision':
    case 'revisi':
    case 'rejected':
    case 'ditolak':
      return DsStatus.revision;
    case 'submitted':
    case 'diajukan':
    case 'pending':
    case 'review':
      return DsStatus.submitted;
    default:
      return DsStatus.draft;
  }
}

/// Status formulir: draft / diajukan / revisi / disetujui.
class DsStatusPill extends StatelessWidget {
  final DsStatus status;
  const DsStatusPill(this.status, {super.key});

  factory DsStatusPill.raw(String? raw, {Key? key}) =>
      DsStatusPill(dsStatusFrom(raw), key: key);

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      DsStatus.draft => ('Draft', AppColors.muted, Icons.edit_note_rounded),
      DsStatus.submitted =>
        ('Diajukan', AppColors.info, Icons.hourglass_top_rounded),
      DsStatus.revision =>
        ('Perlu revisi', AppColors.warning, Icons.replay_rounded),
      DsStatus.approved =>
        ('Disetujui', AppColors.success, Icons.check_circle_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(label,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 12)),
      ]),
    );
  }
}

/// Avatar lingkaran berisi inisial.
class DsAvatar extends StatelessWidget {
  final String? name;
  final double size;
  final Color? background;

  const DsAvatar({super.key, this.name, this.size = 44, this.background});

  static String initials(String? name) {
    final parts = (name ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts[1].characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? AppColors.limeSoft,
        shape: BoxShape.circle,
      ),
      child: Text(initials(name),
          style: TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: size * 0.36)),
    );
  }
}

/// Judul bagian dengan aksi opsional di kanan.
class DsSectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const DsSectionTitle(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ]),
    );
  }
}

/// Tombol CTA lime penuh lebar.
class DsCta extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;

  const DsCta({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.4, color: AppColors.ink))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
                Text(label),
              ]),
      ),
    );
  }
}

/// Bilah CTA yang menempel di bawah layar (mis. "Simpan", "Ajukan").
class DsStickyCta extends StatelessWidget {
  final Widget child;
  const DsStickyCta({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: child,
    );
  }
}

/// Kotak statistik: angka besar + label.
class DsStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool highlight;

  const DsStat({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = highlight ? AppColors.lime : cs.surfaceContainerLowest;
    final fg = highlight ? AppColors.ink : cs.onSurface;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: highlight ? AppColors.lime : cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: fg),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: fg,
                  height: 1)),
          const SizedBox(height: 4),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: highlight ? AppColors.ink : cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Kolom pencarian berbentuk pil.
class DsSearchField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;

  const DsSearchField({
    super.key,
    this.controller,
    this.hint = 'Cari…',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.onSurface, width: 1.6),
        ),
      ),
    );
  }
}

/// Keadaan kosong yang ramah.
class DsEmpty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DsEmpty({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: AppColors.limeSoft, shape: BoxShape.circle),
            child: Icon(icon, size: 32, color: AppColors.ink),
          ),
          const SizedBox(height: 18),
          Text(title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
          ],
          if (actionLabel != null) ...[
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ]),
      ),
    );
  }
}

/// Kartu galat dengan tombol coba lagi.
class DsError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const DsError({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(children: [
        Icon(Icons.error_outline_rounded, color: cs.onErrorContainer),
        const SizedBox(width: 12),
        Expanded(
            child: Text(message,
                style: TextStyle(color: cs.onErrorContainer))),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: const Text('Coba lagi')),
      ]),
    );
  }
}

/// Bingkai halaman: judul besar + isi. Untuk layar tab tanpa AppBar.
class DsPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const DsPageHeader(
      {super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ]),
      ),
      if (trailing != null) trailing!,
    ]);
  }
}

/// Tombol ikon bulat (kembali, bagikan, dsb).
class DsRoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  const DsRoundIcon({super.key, required this.icon, this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: cs.surfaceContainerLowest,
        shape: CircleBorder(side: BorderSide(color: cs.outlineVariant)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
              width: 44, height: 44, child: Icon(icon, size: 22, color: cs.onSurface)),
        ),
      ),
    );
  }
}
