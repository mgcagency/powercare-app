import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'custom_text.dart';

class CustomDropdown<T> extends StatefulWidget {
  final T? value;
  final String hint;
  final String? hintText;
  final String? label;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool readOnly;
  final bool searchable;
  final String searchHint;
  final Color? backColor;
  final bool closeOnSelect;
  final bool isFullWidth;
  final String Function(T)? itemAsString;
  final bool Function(T?, T?)? isSameValue;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    this.value,
    this.hint = 'Select',
    this.hintText,
    this.label,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.readOnly = false,
    this.searchable = true,
    this.searchHint = 'Search...',
    this.itemAsString,
    this.isSameValue,
    this.backColor,
    this.closeOnSelect = true,
    this.isFullWidth = true,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  final ScrollController _scrollController = ScrollController();

  OverlayEntry? _overlayEntry;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<DropdownMenuItem<T>> _filteredItems = [];
  bool _isOpen = false;
  T? _selectedValue;

  bool get _isDisabled => widget.readOnly || !widget.enabled || widget.onChanged == null;
  T? get _effectiveValue => _selectedValue ?? widget.value;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _filteredItems = List<DropdownMenuItem<T>>.from(widget.items);
    _searchController.addListener(_filterItems);
  }

  @override
  void didUpdateWidget(covariant CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
    }

    if (oldWidget.items != widget.items || oldWidget.value != widget.value) {
      _updateFilteredItems();
    }

    if (_isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isOpen) {
          _overlayEntry?.markNeedsBuild();
        }
      });
    }

    if (_isDisabled && _isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isOpen) {
          _closeDropdown();
        }
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();

    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // EQUALITY COMPARISON
  // ---------------------------------------------------------------------------

  bool _isSameValue(T? a, T? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (identical(a, b)) return true;
    if (a == b) return true;
    if (widget.isSameValue != null) return widget.isSameValue!(a, b);

    try {
      final dynamic dynamicA = a;
      final dynamic dynamicB = b;

      if (dynamicA.id != null && dynamicB.id != null) {
        if (dynamicA.id.toString() == dynamicB.id.toString()) return true;
      }
      if (dynamicA.email != null && dynamicB.email != null) {
        if (dynamicA.email.toString() == dynamicB.email.toString()) return true;
      }
      if (dynamicA.materialName != null && dynamicB.materialName != null) {
        if (dynamicA.materialName.toString() == dynamicB.materialName.toString()) return true;
      }
      if (dynamicA.name != null && dynamicB.name != null) {
        if (dynamicA.name.toString() == dynamicB.name.toString()) return true;
      }
      if (dynamicA.status != null && dynamicB.status != null) {
        if (dynamicA.status.toString() == dynamicB.status.toString()) return true;
      }
    } catch (_) {}

    return false;
  }

  // ---------------------------------------------------------------------------
  // SEARCH & FILTERING
  // ---------------------------------------------------------------------------

  void _filterItems() {
    if (!mounted) return;

    _updateFilteredItems();

    if (_isOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _isOpen) {
          _overlayEntry?.markNeedsBuild();
        }
      });
    }
  }

  void _updateFilteredItems() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      _filteredItems = List<DropdownMenuItem<T>>.from(widget.items);
      return;
    }

    _filteredItems = widget.items.where((item) {
      return _getItemText(item).toLowerCase().contains(query);
    }).toList();
  }

  String _getItemText(DropdownMenuItem<T> item) {
    if (widget.itemAsString != null && item.value != null) {
      return widget.itemAsString!(item.value as T);
    }

    if (item.value != null) {
      final dynamic val = item.value;
      try {
        if (val.email != null && val.email.toString().isNotEmpty) {
          return val.email.toString();
        }
      } catch (_) {}
      try {
        if (val.materialName != null && val.materialName.toString().isNotEmpty) {
          return val.materialName.toString();
        }
      } catch (_) {}
      try {
        if (val.name != null && val.name.toString().isNotEmpty) {
          return val.name.toString();
        }
      } catch (_) {}
      try {
        if (val.companyName != null && val.companyName.toString().isNotEmpty) {
          return val.companyName.toString();
        }
      } catch (_) {}
      try {
        if (val.status != null && val.status.toString().isNotEmpty) {
          return val.status.toString();
        }
      } catch (_) {}
    }

    final String extracted = _extractTextFromWidget(item.child);
    if (extracted.isNotEmpty) return extracted;

    return item.value?.toString() ?? '';
  }

  String _extractTextFromWidget(Widget w) {
    if (w is Text) {
      return w.data ?? '';
    }

    if (w is CustomText) {
      return w.text;
    }

    if (w is SingleChildRenderObjectWidget && w.child != null) {
      return _extractTextFromWidget(w.child!);
    }

    if (w is MultiChildRenderObjectWidget) {
      String result = "";
      if (w is Flex) {
        for (var child in w.children) {
          result += "${_extractTextFromWidget(child)} ";
        }
      }
      return result.trim();
    }

    if (w is ProxyWidget) {
      return _extractTextFromWidget(w.child);
    }

    if (w is Container && w.child != null) {
      return _extractTextFromWidget(w.child!);
    }

    if (w is DecoratedBox && w.child != null) {
      return _extractTextFromWidget(w.child!);
    }

    if (w is Padding && w.child != null) {
      return _extractTextFromWidget(w.child!);
    }

    if (w is Expanded) {
      return _extractTextFromWidget(w.child);
    }

    if (w is Flexible) {
      return _extractTextFromWidget(w.child);
    }

    return '';
  }

  // ---------------------------------------------------------------------------
  // DROPDOWN OPEN / CLOSE
  // ---------------------------------------------------------------------------

  void _toggleDropdown() {
    if (_isDisabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    if (_isOpen || !mounted) return;

    FocusScope.of(context).unfocus();

    _searchController.clear();
    _filteredItems = List<DropdownMenuItem<T>>.from(widget.items);

    final overlay = _createOverlayEntry();
    Overlay.of(context).insert(overlay);

    setState(() {
      _overlayEntry = overlay;
      _isOpen = true;
    });
  }

  void _closeDropdown() {
    if (!_isOpen && _overlayEntry == null) return;

    _searchFocusNode.unfocus();
    final overlay = _overlayEntry;
    _overlayEntry = null;

    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }

    if (overlay != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          overlay.remove();
        } catch (_) {}
      });
    }
  }

  void _removeOverlay() {
    final overlay = _overlayEntry;
    _overlayEntry = null;

    if (overlay != null) {
      try {
        overlay.remove();
      } catch (_) {}
    }

    _isOpen = false;
  }

  void _selectItem(T? val) {
    setState(() {
      _selectedValue = val;
    });
    widget.onChanged?.call(val);
    if (widget.closeOnSelect) {
      _closeDropdown();
    } else {
      _updateFilteredItems();
      _overlayEntry?.markNeedsBuild();
    }
  }

  // ---------------------------------------------------------------------------
  // OVERLAY CREATION
  // ---------------------------------------------------------------------------

  OverlayEntry _createOverlayEntry() {
    final renderObject = context.findRenderObject();

    if (renderObject is! RenderBox) {
      return OverlayEntry(
        builder: (_) => const SizedBox.shrink(),
      );
    }

    final renderBox = renderObject;
    final size = renderBox.size;

    final offset = renderBox.localToGlobal(Offset.zero);
    final availableHeightBelow =
        MediaQuery.of(context).size.height - offset.dy - size.height;
    final bool openUpwards = availableHeightBelow < 300 && offset.dy > 300;

    final double overlayWidth = widget.isFullWidth
        ? size.width
        : math.max(size.width, 200.0);

    return OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            // Full-screen backdrop to dismiss overlay when tapping outside
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _closeDropdown,
              child: const SizedBox.expand(),
            ),
            // Positioned overlay dropdown container
            Positioned(
              width: overlayWidth,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                followerAnchor:
                    openUpwards ? Alignment.bottomLeft : Alignment.topLeft,
                targetAnchor:
                    openUpwards ? Alignment.topLeft : Alignment.bottomLeft,
                offset: Offset(
                  0,
                  openUpwards ? -6 : 6,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: _buildDropdownOverlay(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // OVERLAY CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildDropdownOverlay() {
    final bool showSearch = widget.searchable && widget.items.length > 5;

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 320,
      ),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSearch) _buildSearchField(),
          if (showSearch)
            const Divider(
              height: 1,
              thickness: 1,
              color: AppColors.border,
            ),
          Flexible(
            child: _buildItems(showSearch),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textColor,
        ),
        decoration: InputDecoration(
          hintText: widget.searchHint,
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.darkGrey,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.darkGrey,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.darkGrey),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.background,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildItems(bool showSearch) {
    if (_filteredItems.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: CustomText(
            'No results found',
            style: AppTextStyles.bodySmall,
            txtColor: AppColors.darkGrey,
          ),
        ),
      );
    }

    return RawScrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      thumbColor: AppColors.primary,
      thickness: 4,
      radius: const Radius.circular(8),
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        padding: showSearch
            ? const EdgeInsets.symmetric(vertical: 4)
            : EdgeInsets.zero,
        itemCount: _filteredItems.length,
        itemBuilder: (context, index) {
          final item = _filteredItems[index];
          final bool isSelected = _isSameValue(item.value, _effectiveValue);
          return _buildDropdownItem(
            item,
            isSelected,
          );
        },
      ),
    );
  }

  Widget _buildDropdownItem(
    DropdownMenuItem<T> item,
    bool isSelected,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _selectItem(item.value);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        color: isSelected
            ? AppColors.primary.withOpacity(0.08)
            : Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: DefaultTextStyle(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: item.child,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedChild() {
    final currentVal = _effectiveValue;
    try {
      final selected = widget.items.firstWhere(
        (item) => _isSameValue(item.value, currentVal),
      );

      return selected.child;
    } catch (_) {
      final String effectiveHint = widget.hintText ?? widget.hint;
      return CustomText(
        effectiveHint,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkGrey,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // MAIN FIELD UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final String effectiveHint = widget.hintText ?? widget.hint;
    final T? currentVal = _effectiveValue;
    final bool hasSelection = currentVal != null &&
        widget.items.any((item) => _isSameValue(item.value, currentVal));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: CustomText(
              widget.label!,
              style: AppTextStyles.bodyExtraSmall.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleDropdown,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: widget.isFullWidth ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: _isDisabled
                    ? AppColors.readOnlyBg
                    : (widget.backColor ?? Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isOpen
                      ? AppColors.primary
                      : AppColors.border,
                  width: _isOpen ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(
                      widget.prefixIcon,
                      color: _isDisabled ? AppColors.grey : AppColors.darkGrey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: !hasSelection
                        ? CustomText(
                            effectiveHint,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.darkGrey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : DefaultTextStyle(
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: _isDisabled ? AppColors.darkGrey : AppColors.textColor,
                            ),
                            child: _getSelectedChild(),
                          ),
                  ),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _isDisabled ? AppColors.grey : AppColors.darkGrey,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
