import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/part.dart';
import '../providers/parts_provider.dart';

class PartSearchField extends StatefulWidget {
  const PartSearchField({
    super.key,
    required this.onPartSelected,
    this.hintText = 'Search by part code or description',
  });

  final ValueChanged<Part> onPartSelected;
  final String hintText;

  @override
  State<PartSearchField> createState() => _PartSearchFieldState();
}

class _PartSearchFieldState extends State<PartSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  List<Part> _suggestions = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _suggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final provider = context.read<PartsProvider>();
    final results = await provider.searchParts(query);
    if (!mounted) {
      return;
    }
    setState(() {
      _suggestions = results;
      _isSearching = false;
    });
  }

  void _selectPart(Part part) {
    _controller.text = part.displayLabel;
    _focusNode.unfocus();
    setState(() => _suggestions = []);
    widget.onPartSelected(part);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: 'Part',
            hintText: widget.hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _suggestions = []);
                        },
                      )
                    : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: _search,
        ),
        if (_suggestions.isNotEmpty)
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final part = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: Text(part.partNo),
                    subtitle: part.description != null
                        ? Text(
                            '${part.description!} • ${part.weightKg} kg',
                          )
                        : Text('${part.weightKg} kg'),
                    onTap: () => _selectPart(part),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
