import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants/theme.dart';

class LandlordAddPropertyScreen extends StatefulWidget {
  const LandlordAddPropertyScreen({super.key});

  @override
  State<LandlordAddPropertyScreen> createState() => _LandlordAddPropertyScreenState();
}

class _LandlordAddPropertyScreenState extends State<LandlordAddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _sizeController = TextEditingController();
  final _priceController = TextEditingController();

  String _propertyType = 'Apartment';
  List<File> _selectedImages = [];
  List<String> _selectedAmenities = [];
  bool _isLoading = false;

  // Location coordinates
  double? _latitude;
  double? _longitude;

  final List<String> _availableAmenities = [
    'WiFi',
    'Parking',
    'Air Conditioning',
    'Heating',
    'Laundry',
    'Gym',
    'Swimming Pool',
    'Pet Friendly',
    'Security',
    'Furnished',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      if (images.length + _selectedImages.length > 10) {
        Get.snackbar(
          'Limit Exceeded',
          'You can only upload up to 10 images',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      setState(() {
        _selectedImages.addAll(images.map((xFile) => File(xFile.path)).toList());
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _pickLocation() async {
    // Show dialog with manual location input
    showDialog(
      context: context,
      builder: (context) {
        final latController = TextEditingController(
          text: _latitude?.toString() ?? '',
        );
        final lngController = TextEditingController(
          text: _longitude?.toString() ?? '',
        );

        return AlertDialog(
          title: const Text('Set Location'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the property location coordinates',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: latController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  hintText: '-25.7479',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lngController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  hintText: '28.2293',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _latitude = double.tryParse(latController.text);
                  _longitude = double.tryParse(lngController.text);
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
              ),
              child: const Text('Set Location'),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId == null) return imageUrls;

    for (int i = 0; i < _selectedImages.length; i++) {
      final file = _selectedImages[i];
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
      final filePath = '$userId/$fileName';

      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('house-images')
          .upload(filePath, file);

      // Get public URL
      final downloadUrl = Supabase.instance.client.storage
          .from('house-images')
          .getPublicUrl(filePath);

      imageUrls.add(downloadUrl);
    }

    return imageUrls;
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.length < 3) {
      Get.snackbar(
        'Images Required',
        'Please upload at least 3 images of the property',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Upload images
      final imageUrls = await _uploadImages();

      // Create property in Supabase
      await Supabase.instance.client.from('houses').insert({
        'landlord_id': userId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'house_type': _propertyType,
        'street_address': _addressController.text,
        'city': _cityController.text,
        'province': _stateController.text,
        'latitude': _latitude ?? 0.0,
        'longitude': _longitude ?? 0.0,
        'total_rooms': int.tryParse(_bedroomsController.text) ?? 0,
        'total_bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
        'cover_image_url': imageUrls.isNotEmpty ? imageUrls[0] : null,
        'is_active': true,
        'is_verified': false,
        'total_views': 0,
      });

      Get.snackbar(
        'Success',
        'Property added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add property: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: screenBGColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: charcoalBlack),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add New Property',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Property Photos', 'Add at least 3 photos'),
                const SizedBox(height: 12),
                _buildPhotoUploader(),
                const SizedBox(height: 24),

                _buildSectionTitle('Property Details', 'Basic information'),
                const SizedBox(height: 12),
                _buildTextField(_titleController, 'Property Title', 'e.g., Modern 2BR Apartment', validator: true),
                const SizedBox(height: 16),
                _buildTextField(_descriptionController, 'Description', 'Describe your property...', maxLines: 4, validator: true),
                const SizedBox(height: 16),
                _buildDropdown(),
                const SizedBox(height: 24),

                _buildSectionTitle('Location', 'Property address'),
                const SizedBox(height: 12),
                _buildTextField(_addressController, 'Full Address', 'Street address', validator: true),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildTextField(_cityController, 'City', 'City', validator: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextField(_stateController, 'Province', 'Province', validator: true)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildLocationPicker(),
                const SizedBox(height: 24),

                _buildSectionTitle('Property Features', 'Rooms and size'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_bedroomsController, 'Bedrooms', '0',
                        keyboardType: TextInputType.number, validator: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(_bathroomsController, 'Bathrooms', '0',
                        keyboardType: TextInputType.number, validator: true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_sizeController, 'Size (sqm)', '0',
                        keyboardType: TextInputType.number, validator: true),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(_priceController, 'Price/month (R)', '0',
                        keyboardType: TextInputType.number, validator: true),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _buildSectionTitle('Amenities', 'Select available amenities'),
                const SizedBox(height: 12),
                _buildAmenities(),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitProperty,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: whiteColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Add Property',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: charcoalBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: charcoalBlack.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploader() {
    return Column(
      children: [
        if (_selectedImages.isEmpty)
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: InkWell(
              onTap: _pickImages,
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_photo_alternate, size: 48, color: primaryColor),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload Photos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'At least 3 images required',
                    style: TextStyle(
                      fontSize: 13,
                      color: charcoalBlack.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return InkWell(
                      onTap: _pickImages,
                      child: Container(
                        decoration: BoxDecoration(
                          color: whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: const Icon(Icons.add, color: primaryColor, size: 32),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      if (index == 0)
                        const Positioned(
                          bottom: 4,
                          left: 4,
                          child: Chip(
                            label: Text(
                              'Cover',
                              style: TextStyle(fontSize: 10, color: Colors.white),
                            ),
                            backgroundColor: primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedImages.length}/10 images uploaded',
                style: TextStyle(
                  fontSize: 12,
                  color: charcoalBlack.withOpacity(0.6),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint,
      {int maxLines = 1, TextInputType? keyboardType, bool validator = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: charcoalBlack.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14,
              color: charcoalBlack.withOpacity(0.4),
            ),
            filled: true,
            fillColor: whiteColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: primaryColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: charcoalBlack.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _propertyType,
              isExpanded: true,
              items: ['Apartment', 'House', 'Studio', 'Shared Room', 'Condo', 'Townhouse']
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _propertyType = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationPicker() {
    return InkWell(
      onTap: _pickLocation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.location_on, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _latitude != null && _longitude != null
                        ? 'Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}'
                        : 'Tap to set property coordinates',
                    style: TextStyle(
                      fontSize: 12,
                      color: charcoalBlack.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: charcoalBlack.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildAmenities() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _availableAmenities.map((amenity) {
        final isSelected = _selectedAmenities.contains(amenity);
        return InkWell(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedAmenities.remove(amenity);
              } else {
                _selectedAmenities.add(amenity);
              }
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : whiteColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? primaryColor : Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            child: Text(
              amenity,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : charcoalBlack,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
