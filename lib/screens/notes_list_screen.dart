import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/database_service.dart';
import '../widgets/interactive_background.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatefulWidget {
  final DatabaseService databaseService;

  const NotesListScreen({super.key, required this.databaseService});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'updated'; // 'updated', 'created', 'alpha'
  
  final List<String> _categories = ['All', 'Ideas', 'Work', 'Personal', 'Todo', 'Urgent'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: InteractiveBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildFilterBar(),
              Expanded(
                child: _buildNotesGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  // Header design
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AETHER',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: const Color(0xFF3B82F6).withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'My Notes',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          // Online / Offline Badge
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: widget.databaseService.isMock
                      ? Colors.amber.withOpacity(0.12)
                      : Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: widget.databaseService.isMock
                        ? Colors.amber.withOpacity(0.3)
                        : Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.databaseService.isMock
                            ? Colors.amber
                            : Colors.green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.databaseService.isMock
                                ? Colors.amber.withOpacity(0.5)
                                : Colors.green.withOpacity(0.5),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.databaseService.isMock ? 'Mock Offline' : 'Cloud Firestore',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: widget.databaseService.isMock
                            ? Colors.amber.shade200
                            : Colors.green.shade200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Filter Bar (Search + Categories + Sort)
  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Column(
        children: [
          // Search input and Sorting
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        hintText: 'Search title or description...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                        prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
                          borderSide: BorderSide(color: const Color(0xFF3B82F6).withOpacity(0.6)),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Sort dropdown
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _sortBy,
                        dropdownColor: const Color(0xFF1E293B),
                        icon: Icon(Icons.swap_vert, color: Colors.white.withOpacity(0.7)),
                        style: GoogleFonts.outfit(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'updated', child: Text('Sort: Recent')),
                          DropdownMenuItem(value: 'created', child: Text('Sort: Created')),
                          DropdownMenuItem(value: 'alpha', child: Text('Sort: A-Z')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _sortBy = val;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          // Category chips list
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, idx) {
                final cat = _categories[idx];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      cat,
                      style: GoogleFonts.outfit(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.6),
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.8),
                    backgroundColor: Colors.white.withOpacity(0.06),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // Load and Filter Notes from database service stream
  Widget _buildNotesGrid() {
    return StreamBuilder<List<Note>>(
      stream: widget.databaseService.getNotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading notes: ${snapshot.error}',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final allNotes = snapshot.data ?? [];

        // Apply filters
        var filteredNotes = allNotes.where((note) {
          final matchesSearch = note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.description.toLowerCase().contains(_searchQuery.toLowerCase());
          final matchesCategory = _selectedCategory == 'All' || note.category == _selectedCategory;
          return matchesSearch && matchesCategory;
        }).toList();

        // Apply sorting
        if (_sortBy == 'updated') {
          filteredNotes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        } else if (_sortBy == 'created') {
          filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } else if (_sortBy == 'alpha') {
          filteredNotes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        }

        if (filteredNotes.isEmpty) {
          return _buildEmptyState();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Compute cross axis count based on layout width (responsive grid)
            int crossAxisCount = 2;
            if (constraints.maxWidth > 900) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth > 600) {
              crossAxisCount = 3;
            }

            return GridView.builder(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 90),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              itemCount: filteredNotes.length,
              itemBuilder: (context, idx) {
                final note = filteredNotes[idx];
                return _buildNoteCard(context, note);
              },
            );
          },
        );
      },
    );
  }

  // Premium Empty State design
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.note_alt_outlined,
              size: 56,
              color: const Color(0xFF3B82F6).withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _searchQuery.isNotEmpty ? 'No Matching Notes' : 'Thoughts Await',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              _searchQuery.isNotEmpty
                  ? 'Try refining your query or resetting category filters.'
                  : 'Start capturing your notes, thoughts, and tasks in one fluid workspace.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Beautiful Glassmorphic Note Card
  Widget _buildNoteCard(BuildContext context, Note note) {
    final noteColor = Color(note.colorValue);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Open edit screen
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, anim1, anim2) => AddEditNoteScreen(
                databaseService: widget.databaseService,
                note: note,
              ),
              transitionsBuilder: (context, anim, secondaryAnim, child) {
                return FadeTransition(opacity: anim, child: child);
              },
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header (Category Tag & Color Glow Dot)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: noteColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: noteColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          note.category,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: noteColor,
                          ),
                        ),
                      ),
                      // Glow Dot
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: noteColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: noteColor.withOpacity(0.8),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Note Title
                  Text(
                    note.title.isNotEmpty ? note.title : 'Untitled',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Note Description
                  Expanded(
                    child: Text(
                      note.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.55),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date and Quick actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(note.updatedAt),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      // Delete Quick Action
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.white.withOpacity(0.35),
                        ),
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onPressed: () => _confirmDelete(context, note),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Format date helper
  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);
    if (difference.inMinutes < 60) {
      if (difference.inMinutes <= 1) return 'Just now';
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  // Confirm Note Deletion Dialog
  void _confirmDelete(BuildContext context, Note note) {
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
                'Are you sure you want to permanently delete "${note.title}"?',
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
                    Navigator.of(ctx).pop();
                    try {
                      await widget.databaseService.deleteNote(note.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Note "${note.title}" deleted'),
                            backgroundColor: Colors.redAccent.withOpacity(0.9),
                          ),
                        );
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

  // Glassmorphic Glowing floating action button
  Widget _buildFloatingActionButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, anim1, anim2) => AddEditNoteScreen(
                databaseService: widget.databaseService,
              ),
              transitionsBuilder: (context, anim, secondaryAnim, child) {
                return FadeTransition(opacity: anim, child: child);
              },
            ),
          );
        },
        backgroundColor: const Color(0xFF3B82F6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
