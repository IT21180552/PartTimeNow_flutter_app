import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parttimenow_flutter/resources/auth_method.dart';
import 'package:parttimenow_flutter/utils/colors.dart';
import 'package:parttimenow_flutter/utils/global_variable.dart';
// import 'package:parttimenow_flutter/utils/global_variable.dart';
// import 'package:parttimenow_flutter/utils/utills.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({Key? key}) : super(key: key);

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int descriptionLength = 0;
  bool isPosting = false;

  String? validateRequiredField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    descriptionController.addListener(() {
      setState(() {
        descriptionLength = descriptionController.text.length;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    startDateController.dispose();
    startTimeController.dispose();
    endDateController.dispose();
    endTimeController.dispose();
    salaryController.dispose();
    locationController.dispose();
    descriptionController.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = formatDate(picked);
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  String formatTime(DateTime time) {
    final formatter = DateFormat('h:mm a');
    return formatter.format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post a Job'),
        backgroundColor: mobileBackgroundColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8, top: 40),
                      child: buildRoundedTextField(
                          'Start Date', startDateController, _selectDate),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8, top: 40),
                      child: buildRoundedTextField(
                          'Start Time', startTimeController, _selectTime),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: buildRoundedTextField(
                          'End Date', endDateController, _selectDate),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: buildRoundedTextField(
                          'End Time', endTimeController, _selectTime),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              buildSalaryField(),
              const SizedBox(height: 20),
              buildLocationField(),
              const SizedBox(height: 20),
              buildDescriptionField(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isPosting ? null : () => _postJob(),
                style: ElevatedButton.styleFrom(
                  primary: mobileBackgroundColor,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size(150, 40),
                ),
                child: Text(
                  isPosting ? 'Posting...' : 'Post Job',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _postJob() async {
    if (descriptionLength > 200) {
      showValidationError("Character limit exceeded!");
    } else {
      final validationError = getRequiredFieldsValidation();
      if (validationError != null) {
        showValidationError(validationError);
      } else {
        setState(() {
          isPosting = true;
        });

        logger.d("Post Job button pressed");

        final startDate = DateTime.parse(startDateController.text);
        final endDate = DateTime.parse(endDateController.text);

        if (endDate.isBefore(startDate)) {
          showValidationError("End date must be after or equal to start date");
          setState(() {
            isPosting = false;
          });
        } else {
          final salary = double.parse(salaryController.text);
          final location = locationController.text;
          final description = descriptionController.text;

          await AuthMethod().postJob(
            startDate: startDate,
            endDate: endDate,
            salary: salary,
            location: location,
            description: description,
            startTime: startTimeController.text,
            endTime: endTimeController.text,
          );

          setState(() {
            isPosting = false;
          });

          startDateController.clear();
          startTimeController.clear();
          endDateController.clear();
          endTimeController.clear();
          salaryController.clear();
          locationController.clear();
          descriptionController.clear();
        }
      }
    }
  }

  void showValidationError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: Colors.red,
      ),
    );
  }

  String? getRequiredFieldsValidation() {
    if (startDateController.text.isEmpty ||
        startTimeController.text.isEmpty ||
        endDateController.text.isEmpty ||
        endTimeController.text.isEmpty ||
        salaryController.text.isEmpty ||
        locationController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      return "All the fields are required";
    }
    return null;
  }

  Widget buildRoundedTextField(
      String labelText,
      TextEditingController controller,
      Function(BuildContext, TextEditingController) onTapFunction) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        hintText: 'Enter a value',
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 206, 124, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      onTap: () {
        onTapFunction(context, controller);
      },
    );
  }

  Widget buildSalaryField() {
    return TextField(
      controller: salaryController,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Salary',
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        hintText: '30000',
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 206, 124, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildLocationField() {
    return TextField(
      controller: locationController,
      style: const TextStyle(color: Colors.black, fontSize: 14),
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        labelText: 'Location',
        labelStyle: const TextStyle(
          color: Colors.black,
          fontSize: 14,
        ),
        hintText: 'Enter a location',
        hintStyle: const TextStyle(color: Colors.grey),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 206, 124, 0)),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }

  Widget buildDescriptionField() {
    return Stack(
      children: [
        TextField(
          controller: descriptionController,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          maxLines: 6,
          decoration: InputDecoration(
            labelText: 'Description',
            labelStyle: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            hintText: 'Enter a description',
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(15),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: descriptionLength <= 200
                    ? Color.fromARGB(255, 255, 162, 22)
                    : Colors.red,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Text(
            '${descriptionLength.toString()} / 200',
            style: TextStyle(
              color: descriptionLength <= 200 ? Colors.grey : Colors.red,
            ),
          ),
        ),
      ],
    );
  }
}