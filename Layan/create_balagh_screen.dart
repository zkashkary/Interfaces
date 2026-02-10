import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateBalaghScreen extends StatefulWidget {
  const CreateBalaghScreen({super.key});

  @override
  State<CreateBalaghScreen> createState() => _CreateBalaghScreenState();
}

class _CreateBalaghScreenState extends State<CreateBalaghScreen> {
  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationDetailsController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Form state
  String selectedSection = 'male'; // 'male' or 'female'
  String selectedCategory = 'electricity';
  String? selectedBuildingId;
  String? selectedBuildingName;
  File? selectedImage;
  bool isSubmitting = false;

  // Available buildings in Arabic
  final List<Map<String, String>> buildings = [
    {'id': '239', 'name': 'مبنى التلفزيون - 239'},
    {'id': '203', 'name': 'مبنى المكتبة - 203'},
    {'id': '209', 'name': 'مبنى العلوم - 209'},
  ];

  // Categories in Arabic
  final List<Map<String, dynamic>> categories = [
    {'value': 'electricity', 'label': 'كهرباء', 'icon': Icons.bolt},
    {'value': 'furniture', 'label': 'أثاث', 'icon': Icons.chair},
    {'value': 'air_conditioning', 'label': 'تكييف', 'icon': Icons.ac_unit},
    {'value': 'damages', 'label': 'عاجلة', 'icon': Icons.build},
    {'value': 'plumbing', 'label': 'سباكة', 'icon': Icons.water_drop},
    {'value': 'other', 'label': 'أخرى', 'icon': Icons.info_outline},
  ];

  @override
  void dispose() {
    titleController.dispose();
    locationDetailsController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show dialog to choose camera or gallery
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'اختر مصدر الصورة',
          textAlign: TextAlign.right,
          style: TextStyle(fontFamily: 'Arial'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              trailing: const Icon(Icons.camera_alt),
              title: const Text(
                'الكاميرا',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Arial'),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              trailing: const Icon(Icons.photo_library),
              title: const Text(
                'المعرض',
                textAlign: TextAlign.right,
                style: TextStyle(fontFamily: 'Arial'),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    }
  }

  Future<void> _submitReport() async {
    // Validate required fields
    if (titleController.text.trim().isEmpty) {
      _showError('الرجاء إدخال عنوان البلاغ');
      return;
    }

    if (selectedBuildingId == null) {
      _showError('الرجاء اختيار المبنى');
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      _showError('الرجاء وصف المشكلة');
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // TODO: Upload image to Firebase Storage if exists
      // TODO: Save report to Firestore
      // For now, just simulate
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم إرسال البلاغ بنجاح!',
              textAlign: TextAlign.right,
              style: TextStyle(fontFamily: 'Arial'),
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        titleController.clear();
        locationDetailsController.clear();
        descriptionController.clear();
        setState(() {
          selectedImage = null;
          selectedBuildingId = null;
          selectedBuildingName = null;
        });
      }
    } catch (e) {
      _showError('فشل في إرسال البلاغ: $e');
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Arial'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Enable RTL
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F0F8),
        appBar: AppBar(
          title: const Text(
            'إنشاء بلاغ',
            style: TextStyle(fontFamily: 'Arial'),
          ),
          backgroundColor: const Color(0xFF1E3A5F),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Title
              _buildSectionCard(
                title: 'عنوان البلاغ',
                child: TextField(
                  controller: titleController,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Arial'),
                  decoration: InputDecoration(
                    hintText: 'وصف موجز للمشكلة',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Arial',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campus Section
              _buildSectionCard(
                title: 'قسم الحرم الجامعي',
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSectionButton(
                        'طلاب',
                        'male',
                        selectedSection == 'male',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSectionButton(
                        'طالبات',
                        'female',
                        selectedSection == 'female',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Category Selection
              _buildSectionCard(
                title: 'الفئة',
                showIcon: true,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories.map((category) {
                    return _buildCategoryChip(
                      category['label'],
                      category['value'],
                      category['icon'],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Building Selection
              _buildSectionCard(
                title: 'المبنى',
                child: Column(
                  children: buildings.map((building) {
                    return _buildBuildingOption(
                      building['id']!,
                      building['name']!,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Location Details
              _buildSectionCard(
                title: 'تفاصيل الموقع',
                showIcon: true,
                child: Column(
                  children: [
                    TextField(
                      controller: locationDetailsController,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontFamily: 'Arial'),
                      decoration: InputDecoration(
                        hintText: 'مثال: الطابق الثاني، القاعة 204',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: 'Arial',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        // TODO: Open map selector
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'محدد الموقع قريباً!',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontFamily: 'Arial'),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.location_on),
                      label: const Text(
                        'اختر الموقع من الخريطة',
                        style: TextStyle(fontFamily: 'Arial'),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Problem Description
              _buildSectionCard(
                title: 'وصف المشكلة',
                child: TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontFamily: 'Arial'),
                  decoration: InputDecoration(
                    hintText: 'صف مشكلة الصيانة بالتفصيل',
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Arial',
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Attach Photo
              _buildSectionCard(
                title: 'إرفاق صورة',
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اضغط لتحميل صورة',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                  fontFamily: 'Arial',
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8, // Changed from right to left for RTL
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedImage = null;
                                    });
                                  },
                                  icon: const Icon(Icons.close),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'يرجى تقديم تفاصيل دقيقة للمساعدة في معالجة تقريرك بشكل أسرع.',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.blue[900],
                          fontSize: 12,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey[400],
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'إرسال',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Arial',
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    bool showIcon = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Arial',
                ),
              ),
              if (showIcon) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4CE6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.build, color: Colors.white, size: 20),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionButton(String label, String value, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSection = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              fontFamily: 'Arial',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, String value, IconData icon) {
    final isSelected = selectedCategory == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Arial',
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF1E3A5F),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBuildingOption(String id, String name) {
    final isSelected = selectedBuildingId == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedBuildingId = id;
            selectedBuildingName = name;
          });
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A5F) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF1E3A5F) : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Arial',
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.business,
                color: isSelected ? Colors.white : const Color(0xFF1E3A5F),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 1, // Create Balagh is selected
        selectedItemColor: const Color(0xFF1E3A5F),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: 'Arial'),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Arial'),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'إنشاء بلاغ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
        onTap: (index) {
          // TODO: Handle navigation
          if (index == 0) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
