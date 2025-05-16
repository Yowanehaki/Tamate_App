import 'package:flutter/material.dart';
import '../models/chapter_model.dart';

class ChapterCard extends StatelessWidget {
  final ChapterModel chapter;
  final int index;
  final Function(bool, int, int) onSectionToggle;
  final Function(int) onExpand;
  final Function(int, int, String) onSectionEdit;
  final Function(int, int) onSectionDelete;
  final Function(int, String) onSectionAdd;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.index,
    required this.onSectionToggle,
    required this.onExpand,
    required this.onSectionEdit,
    required this.onSectionDelete,
    required this.onSectionAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              child: Text('${index + 1}'),
            ),
            title: Text(
              chapter.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Progress: ${(chapter.progress * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: chapter.progress > 0 
                              ? chapter.progress < 1 
                                  ? Colors.orange 
                                  : Colors.green
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      '${chapter.sections.where((s) => s.completed).length}/${chapter.sections.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: chapter.progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      chapter.progress < 0.3
                          ? Colors.red
                          : chapter.progress < 0.7
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Icon(
              chapter.expanded ? Icons.expand_less : Icons.expand_more,
              color: colorScheme.primary,
            ),
            initiallyExpanded: chapter.expanded,
            onExpansionChanged: (expanded) => onExpand(index),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const Divider(),
                    ...List.generate(
                      chapter.sections.length,
                      (sectionIndex) {
                        final section = chapter.sections[sectionIndex];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: section.completed,
                                activeColor: Colors.green,
                                onChanged: (value) {
                                  onSectionToggle(value ?? false, index, sectionIndex);
                                },
                              ),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    onSectionToggle(!section.completed, index, sectionIndex);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        section.title,
                                        style: TextStyle(
                                          decoration: section.completed 
                                              ? TextDecoration.lineThrough 
                                              : null,
                                          color: section.completed 
                                              ? Colors.grey[600] 
                                              : null,
                                        ),
                                      ),
                                      if (section.completed)
                                        const Text(
                                          'Selesai', 
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditSectionDialog(context, index, sectionIndex);
                                  } else if (value == 'delete') {
                                    _showDeleteSectionDialog(context, index, sectionIndex);
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 20, color: colorScheme.primary),
                                        const SizedBox(width: 8),
                                        const Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 20, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Hapus', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                                icon: Icon(
                                  Icons.more_vert,
                                  size: 20,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton.icon(
                        onPressed: () {
                          _showAddSectionDialog(context, index);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Bagian'),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditSectionDialog(BuildContext context, int chapterIndex, int sectionIndex) {
    final textController = TextEditingController(text: chapter.sections[sectionIndex].title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Bagian'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: 'Judul Bagian',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                onSectionEdit(chapterIndex, sectionIndex, textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteSectionDialog(BuildContext context, int chapterIndex, int sectionIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Bagian'),
        content: Text(
          'Apakah Anda yakin ingin menghapus bagian "${chapter.sections[sectionIndex].title}"?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              onSectionDelete(chapterIndex, sectionIndex);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAddSectionDialog(BuildContext context, int chapterIndex) {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Bagian Baru'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'Judul Bagian',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Judul bagian tidak boleh kosong';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                onSectionAdd(chapterIndex, textController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}