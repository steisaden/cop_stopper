import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../app_spacing.dart';
import '../app_text_styles.dart';

/// Bottom sheet picker for selection lists and options
class BottomSheetPicker<T> extends StatelessWidget {
  final String title;
  final List<BottomSheetPickerItem<T>> items;
  final T? selectedValue;
  final ValueChanged<T>? onSelected;
  final bool showSearchBar;
  final String? searchHint;

  const BottomSheetPicker({
    Key? key,
    required this.title,
    required this.items,
    this.selectedValue,
    this.onSelected,
    this.showSearchBar = false,
    this.searchHint,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<BottomSheetPickerItem<T>> items,
    T? selectedValue,
    bool showSearchBar = false,
    String? searchHint,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetPicker<T>(
        title: title,
        items: items,
        selectedValue: selectedValue,
        showSearchBar: showSearchBar,
        searchHint: searchHint,
        onSelected: (value) => Navigator.of(context).pop(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final mediaQuery = MediaQuery.of(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: AppSpacing.paddingXS,
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: AppSpacing.paddingMD,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Search bar
          if (showSearchBar) ...[
            Padding(
              padding: AppSpacing.horizontalPaddingMD,
              child: _SearchBar(
                hint: searchHint ?? 'Search...',
                onChanged: (query) {
                  // TODO: Implement search functionality
                },
              ),
            ),
            AppSpacing.verticalSpaceSM,
          ],
          
          // Items list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.value == selectedValue;
                
                return _PickerItem<T>(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onSelected?.call(item.value),
                );
              },
            ),
          ),
          
          // Bottom safe area
          SizedBox(height: mediaQuery.padding.bottom),
        ],
      ),
    );
  }
}

/// Item for bottom sheet picker
class BottomSheetPickerItem<T> {
  final T value;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  const BottomSheetPickerItem({
    required this.value,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });
}

/// Internal picker item widget
class _PickerItem<T> extends StatelessWidget {
  final BottomSheetPickerItem<T> item;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PickerItem({
    Key? key,
    required this.item,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: AppSpacing.paddingMD,
        decoration: BoxDecoration(
          color: isSelected 
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : null,
        ),
        child: Row(
          children: [
            // Icon
            if (item.icon != null) ...[
              Icon(
                item.icon,
                color: isSelected 
                  ? colorScheme.primary 
                  : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              AppSpacing.horizontalSpaceMD,
            ],
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isSelected 
                        ? colorScheme.primary 
                        : colorScheme.onSurface,
                      fontWeight: isSelected 
                        ? FontWeight.w600 
                        : FontWeight.normal,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    AppSpacing.verticalSpaceXS,
                    Text(
                      item.subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Trailing
            if (item.trailing != null) ...[
              AppSpacing.horizontalSpaceSM,
              item.trailing!,
            ] else if (isSelected) ...[
              AppSpacing.horizontalSpaceSM,
              Icon(
                Icons.check,
                color: colorScheme.primary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Internal search bar widget
class _SearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const _SearchBar({
    Key? key,
    required this.hint,
    this.onChanged,
  }) : super(key: key);

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(
          Icons.search,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: _controller.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                _controller.clear();
                widget.onChanged?.call('');
              },
              icon: Icon(
                Icons.clear,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.buttonBorderRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      ),
    );
  }
}