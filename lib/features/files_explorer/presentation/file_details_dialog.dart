import 'package:ellipsized_text/ellipsized_text.dart';
import 'package:files/core/theme/app_theme.dart';
import 'package:files/core/utils/commons.dart';
import 'package:files/features/files_explorer/blocs/file_boc.dart';
import 'package:files/features/files_explorer/blocs/file_state.dart';
import 'package:files/features/files_home/data/models/file_item.dart';
import 'package:files/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;

class FileDetailsDialog extends StatelessWidget {
  final String path;
  final VoidCallback onClose;

  const FileDetailsDialog({
    super.key,
    required this.path,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FilesBloc>();

    final fileItem = FileItem(
      name: p.basename(path),
      type: p.extension(path).isEmpty ? 'dir' : p.extension(path),
      modified: DateTime.now(),
    );

    return BlocProvider.value(
      value: bloc,
      child: BlocBuilder<FilesBloc, FilesState>(
        builder: (context, state) {
          final details = state.fileDetails;

          if (details == null) {
            return const SizedBox.shrink();
          }

          final hidden = p.basename(path).startsWith('.') ? 'Yes' : 'No';
          final readable = (details.mode & 0x100) != 0 ? 'Yes' : 'No';
          final writable = (details.mode & 0x80) != 0 ? 'Yes' : 'No';

          return Material(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => onClose(),
                      ),
                    ),

                    const Divider(
                      height: 1,
                      color: AppColors.backgroundVariant,
                    ),

                    const SizedBox(height: 8),

                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.fileInfo,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Row(
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 180),
                              child: EllipsizedText(
                                fileItem.name,
                                type: EllipsisType.middle,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Image.asset(
                              fileItem.iconPath,
                              width: 22,
                              height: 22,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),

                    buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.type,
                      details.type.toString(),
                    ),

                    buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.size,
                      formatBytesDecimal(details.size),
                    ),

                    buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.modified,
                      formatDateTime(details.modified),
                    ),

                    buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.accessed,
                      formatDateTime(details.accessed),
                    ),

                    buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.changed,
                      formatDateTime(details.changed),
                    ),

                    buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.readable,
                      readable,
                    ),

                    buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.writable,
                      writable,
                    ),

                    buildDetailRow(
                      context,
                      AppLocalizations.of(context)!.hidden,
                      hidden,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget buildDetailRow(BuildContext context, String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    ),
  );
}
