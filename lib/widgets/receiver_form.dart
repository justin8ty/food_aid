// lib/widgets/receiver_form.dart
import 'package:flutter/material.dart';

class ReceiverForm extends StatefulWidget {
  const ReceiverForm({Key? key}) : super(key: key);

  @override
  _ReceiverFormState createState() => _ReceiverFormState();
}

class _ReceiverFormState extends State<ReceiverForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String _incomeGroup = 'B40';
  bool _hasDisability = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Receiver Form',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _incomeGroup,
                decoration: const InputDecoration(labelText: 'Income Group'),
                items: <String>['B40', 'M40', 'T20']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _incomeGroup = newValue!;
                  });
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Do you have a disability?'),
                  Checkbox(
                    value: _hasDisability,
                    onChanged: (bool? value) {
                      setState(() {
                        _hasDisability = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Process the form data
                    Navigator.of(context).pop(); // Close the form dialog
                    // Handle the form submission, for example save the data.
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}