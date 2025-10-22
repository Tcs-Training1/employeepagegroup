import 'package:flutter/material.dart';

void main() {
  runApp(EmployeeApp());
}

class EmployeeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Form',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: EmployeeFormPage(),
    );
  }
}

class EmployeeFormPage extends StatefulWidget {
  @override
  _EmployeeFormPageState createState() => _EmployeeFormPageState();
}

class _EmployeeFormPageState extends State<EmployeeFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController empIdController = TextEditingController();
  final TextEditingController empNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String empType = "Temporary";
  String office = "ECO 1A";
  DateTime? dob;

  List<Map<String, dynamic>> employees = []; // In-memory JSON list
  int? editIndex;

  // Function to add or update employee
  void submitForm() {
    if (_formKey.currentState!.validate()) {
      final newEmployee = {
        "empId": empIdController.text,
        "empName": empNameController.text,
        "address": addressController.text,
        "empType": empType,
        "office": office,
        "dob": dob != null ? dob.toString().split(" ")[0] : "",
      };

      setState(() {
        if (editIndex == null) {
          employees.add(newEmployee);
        } else {
          employees[editIndex!] = newEmployee;
          editIndex = null;
        }
        clearForm();
      });
    }
  }

  // Function to clear form
  void clearForm() {
    empIdController.clear();
    empNameController.clear();
    addressController.clear();
    empType = "Temporary";
    office = "ECO 1A";
    dob = null;
  }

  // Function to edit employee
  void editEmployee(int index) {
    final emp = employees[index];
    setState(() {
      empIdController.text = emp["empId"];
      empNameController.text = emp["empName"];
      addressController.text = emp["address"];
      empType = emp["empType"];
      office = emp["office"];
      dob = DateTime.tryParse(emp["dob"]);
      editIndex = index;
    });
  }

  // Function to delete employee
  void deleteEmployee(int index) {
    setState(() {
      employees.removeAt(index);
    });
  }

  // Date picker
  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != dob) {
      setState(() {
        dob = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Employee Form")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: empIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Employee ID"),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter Employee ID" : null,
                  ),
                  TextFormField(
                    controller: empNameController,
                    decoration: InputDecoration(labelText: "Employee Name"),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter name" : null,
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: "Address"),
                    validator: (value) =>
                        value!.isEmpty ? "Please enter address" : null,
                  ),
                  SizedBox(height: 10),
                  Text("Employee Type"),
                  Row(
                    children: [
                      Radio<String>(
                        value: "Temporary",
                        groupValue: empType,
                        onChanged: (value) {
                          setState(() => empType = value!);
                        },
                      ),
                      Text("Temporary"),
                      Radio<String>(
                        value: "Permanent",
                        groupValue: empType,
                        onChanged: (value) {
                          setState(() => empType = value!);
                        },
                      ),
                      Text("Permanent"),
                    ],
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: office,
                    decoration: InputDecoration(labelText: "Office Address"),
                    items: ["ECO 1A", "ECO 1B", "GP"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      setState(() => office = value!);
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dob == null
                              ? "Select Date of Birth"
                              : "DOB: ${dob.toString().split(' ')[0]}",
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => pickDate(context),
                        child: Text("Pick Date"),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: submitForm,
                        child: Text(editIndex == null ? "Submit" : "Update"),
                      ),
                      SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            clearForm();
                            editIndex = null;
                          });
                        },
                        child: Text("Reset"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 31),
            Divider(),
            Text(
              "Employee Data",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 11),
            // Employee List (Table)
            ListView.builder(
              shrinkWrap: true,
              itemCount: employees.length,
              itemBuilder: (context, index) {
                final emp = employees[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text("${emp['empName']} (${emp['empId']})"),
                    subtitle: Text(
                      "Address: ${emp['address']}\nType: ${emp['empType']}, Office: ${emp['office']}, DOB: ${emp['dob']}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => editEmployee(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => deleteEmployee(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
