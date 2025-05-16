// lib/features/milestone/milestone_screen.dart
import 'package:flutter/material.dart';

import 'widgets/chapter_card.dart';
import '../manager/milestone_manager.dart';
import '../../../core/services/milestone_service.dart'; // Import service

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  final MilestoneManager _milestoneManager = MilestoneManager();
  final MilestoneService _milestoneService = MilestoneService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _milestoneService.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _milestoneService.removeListener(_onDataChanged);
    super.dispose();
  }

  void _loadData() async {
    await _milestoneService.loadChapters();
    setState(() {
      _isLoading = false;
    });
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Milestone TA')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Milestone TA', 
          style: TextStyle(fontSize: 18),
        ),
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildProgressHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                top: 12.0,
                left: 12.0,
                right: 12.0,
                bottom: 70.0,
              ),
              itemCount: _milestoneService.chapters.length,
              itemBuilder: (context, index) {
                return ChapterCard(
                  chapter: _milestoneService.chapters[index],
                  index: index,
                  onSectionToggle: _handleSectionToggle,
                  onExpand: _handleChapterExpand,
                  onSectionEdit: _handleSectionEdit,
                  onSectionDelete: _handleSectionDelete,
                  onSectionAdd: _handleSectionAdd,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 48,
        height: 48,
        child: FloatingActionButton(
          onPressed: _showAddSectionDialog,
          tooltip: 'Tambah Bagian Baru',
          elevation: 1,
          child: const Icon(Icons.add, size: 20),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProgressHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    final overallProgress = _milestoneService.getOverallProgress();
    final progressColor = overallProgress < 0.3 
        ? Colors.red 
        : overallProgress < 0.7 
            ? Colors.orange 
            : Colors.green;
            
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1.0,
            spreadRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Keseluruhan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                '${(overallProgress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: overallProgress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSectionToggle(bool value, int chapterIndex, int sectionIndex) {
    _milestoneService.updateSectionCompletion(chapterIndex, sectionIndex, value);
    
    // Update milestone manager
    final chapter = _milestoneService.chapters[chapterIndex];
    _milestoneManager.updateChapterProgress(chapterIndex, chapter.progress);
    _milestoneManager.updateOverallProgress(_milestoneService.getOverallProgress());
  }

  void _handleChapterExpand(int chapterIndex) {
    _milestoneService.updateChapterExpanded(
      chapterIndex, 
      !_milestoneService.chapters[chapterIndex].expanded
    );
  }

  void _handleSectionEdit(int chapterIndex, int sectionIndex, String newTitle) {
    _milestoneService.updateSectionTitle(chapterIndex, sectionIndex, newTitle);
  }

  void _handleSectionDelete(int chapterIndex, int sectionIndex) {
    _milestoneService.deleteSection(chapterIndex, sectionIndex);
    
    // Update milestone manager
    final chapter = _milestoneService.chapters[chapterIndex];
    _milestoneManager.updateChapterProgress(chapterIndex, chapter.progress);
    _milestoneManager.updateOverallProgress(_milestoneService.getOverallProgress());
  }

  void _handleSectionAdd(int chapterIndex, String title) {
    _milestoneService.addSection(chapterIndex, title);
    
    // Update milestone manager
    final chapter = _milestoneService.chapters[chapterIndex];
    _milestoneManager.updateChapterProgress(chapterIndex, chapter.progress);
    _milestoneManager.updateOverallProgress(_milestoneService.getOverallProgress());
  }

  void _showAddSectionDialog() {
    int selectedChapterIndex = 0;
    final sectionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: const Text('Tambah Bagian'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      content: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.8,
            minWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Bab',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  value: selectedChapterIndex,
                  items: List.generate(
                    _milestoneService.chapters.length,
                    (index) => DropdownMenuItem(
                      value: index,
                      child: Text(
                        _milestoneService.chapters[index].title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedChapterIndex = value;
                      });
                    }
                  },
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: sectionController,
                  decoration: const InputDecoration(
                    labelText: 'Judul Bagian',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  maxLines: 1,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul bagian tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
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
              _milestoneService.addSection(
                selectedChapterIndex, 
                sectionController.text
              );
              
              // Update milestone manager
              final chapter = _milestoneService.chapters[selectedChapterIndex];
              _milestoneManager.updateChapterProgress(selectedChapterIndex, chapter.progress);
              _milestoneManager.updateOverallProgress(_milestoneService.getOverallProgress());
              
              Navigator.pop(context);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  },
);
  }
}