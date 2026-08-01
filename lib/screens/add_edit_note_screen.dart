import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../widgets/interactive_background.dart';

class AddEditNoteScreen extends StatefulWidget {
  final DatabaseService databaseService;
  final Note? note; // Null if adding a new note

  const AddEditNoteScreen({
    super.key,
    required this.databaseService,
    this.note,
  });

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _category;
  late int _colorValue;

  final List<String> _categories = ['Ideas', 'Work', 'Personal', 'Todo', 'Urgent'];

  // A list of premium glowing colors
  final List<int> _colors = [
    0xFF3B82F6, // Electric Blue
    0xFF14B8A6, // Mint/Teal
    0xFFF59E0B, // Amber/Gold
    0xFFD946EF, // Purple Glow
    0xFFF43F5E, // Rose/Crimson
    0xFF94A3B8, // Sleek Slate
  ];

  @override
  void initState() {
    super.initState();
    _title = widget.note?.title ?? '';
    _description = widget.note?.description ?? '';
    _category = widget.note?.category ?? 'Ideas';
    _colorValue = widget.note?.colorValue ?? 0xFF3B82F6; // Default to Blue
  }

  bool get isEditing => widget.note != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: InteractiveBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFormHeader(),
                  const SizedBox(height: 24),
                  _buildTitleField(),
                  const SizedBox(height: 20),
                  _buildCategorySelector(),
                  const SizedBox(height: 24),
                  _buildColorPicker(),
                  const SizedBox(height: 24),
                  _buildDescriptionField(),
                  const SizedBox(height: 40),
                  _buildSubmitButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Transparent Premium App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
            onPressed: () => _deleteNote(context),
          ),
      ],
    );
  }

  // Header describing editing vs creating
  Widget _buildFormHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isEditing ? 'MODIFY NOTE' : 'NEW INSIGHT',
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
            color: Color(_colorValue).withOpacity(0.9),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isEditing ? 'Edit Note' : 'Create Note',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // Title Text Input Field
  Widget _buildTitleField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          initialValue: _title,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            hintText: 'Note Title',
            hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.35)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(_colorValue).withOpacity(0.6)),
            ),
          ),
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Title is required';
            }
            return null;
          },
          onSaved: (val) {
            _title = val!.trim();
          },
        ),
      ),
    );
  }

  // Category Selector Chips
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _category == cat;
            return ChoiceChip(
              label: Text(
                cat,
                style: GoogleFonts.outfit(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _category = cat;
                  });
                }
              },
              selectedColor: Color(_colorValue).withOpacity(0.8),
              backgroundColor: Colors.white.withOpacity(0.04),
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.white.withOpacity(0.08),
                ),
              ),
            );
          }).toList(),
        )
      ],
    );
  }

  // Color Picker Widget (displays active glowing circles)
  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note Card Accent Color',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colors.length,
            itemBuilder: (context, idx) {
              final colorVal = _colors[idx];
              final color = Color(colorVal);
              final isSelected = _colorValue == colorVal;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _colorValue = colorVal;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    width: isSelected ? 48 : 40,
                    height: isSelected ? 48 : 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(isSelected ? 0.8 : 0.4),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                        width: isSelected ? 2.5 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withOpacity(0.6),
                            blurRadius: 16,
                            spreadRadius: 2,
                          )
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // Description / Note Body Text Input Field
  Widget _buildDescriptionField() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextFormField(
          initialValue: _description,
          maxLines: 8,
          style: GoogleFonts.outfit(
            fontSize: 15,
            color: Colors.white.withOpacity(0.9),
            height: 1.5,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.04),
            hintText: 'Start writing your details, lists, or memories here...',
            hintStyle: GoogleFonts.outfit(color: Colors.white.withOpacity(0.35)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Color(_colorValue).withOpacity(0.6)),
            ),
          ),
          validator: (val) {
            // Note body is optional, but checking if null to prevent crashes
            return null;
          },
          onSaved: (val) {
            _description = val?.trim() ?? '';
          },
        ),
      ),
    );
  }

  // Submit Button
  Widget _buildSubmitButton(BuildContext context) {
    final themeColor = Color(_colorValue);

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () => _saveNote(context),
        child: Text(
          isEditing ? 'Save Changes' : 'Create Note',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  // Save Note logic
  void _saveNote(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final now = DateTime.now();

      final noteToSave = isEditing
          ? widget.note!.copyWith(
              title: _title,
              description: _description,
              category: _category,
              colorValue: _colorValue,
              updatedAt: now,
            )
          : Note(
              id: '', // Generated by service
              title: _title,
              description: _description,
              colorValue: _colorValue,
              category: _category,
              createdAt: now,
              updatedAt: now,
            );

      try {
        if (isEditing) {
          await widget.databaseService.updateNote(noteToSave);
        } else {
          await widget.databaseService.addNote(noteToSave);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'Note updated successfully!' : 'Note created successfully!'),
              backgroundColor: themeColorOverlay(),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving note: $e'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }

  // Delete Note logic (from details menu)
  void _deleteNote(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E293B).withOpacity(0.85),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: Colors.white.withOpacity(0.08), width: 1.2),
              ),
              title: Text(
                'Delete Note',
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to permanently delete this note?',
                style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.7)),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.6)),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop(); // Close dialog
                    try {
                      await widget.databaseService.deleteNote(widget.note!.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Note deleted successfully'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        Navigator.pop(context); // Pop back to list screen
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error deleting note: $e')),
                        );
                      }
                    }
                  },
                  child: Text('Delete', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color themeColorOverlay() {
    return Color(_colorValue).withOpacity(0.9);
  }
}
