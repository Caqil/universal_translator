import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';

class HistorySearch extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback? onClear;
  final String? initialQuery;
  final bool isLoading;

  const HistorySearch({
    super.key,
    required this.onSearch,
    this.onClear,
    this.initialQuery,
    this.isLoading = false,
  });

  @override
  State<HistorySearch> createState() => _HistorySearchState();
}

class _HistorySearchState extends State<HistorySearch> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: (value) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_controller.text == value) {
              widget.onSearch(value);
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'history.search_history'.tr(),
          prefixIcon: widget.isLoading
              ? Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(14),
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onClear?.call();
                    _focusNode.unfocus();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.defaultPadding,
            vertical: AppConstants.smallPadding,
          ),
        ),
      ),
    );
  }
}
