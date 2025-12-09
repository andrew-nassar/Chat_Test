import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon; // Made optional
  final bool isPassword;
  final TextInputType type;
  final String? Function(String?)? validator; // Custom validation logic
  final TextInputAction? action; // Controls the "Enter" key (Next/Done)
  // ✅ 1. Add this field
  final Iterable<String>? autofillHints;
  
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.type = TextInputType.text,
    this.validator, 
    this.action = TextInputAction.next, this.autofillHints,
    
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  // To track password visibility
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0), // Increased spacing
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _isObscured : false,
        keyboardType: widget.type,
        textInputAction: widget.action,
        
        // Use the passed validator, or fallback to a default check
        validator: widget.validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return '${widget.label} is required';
              }
              return null;
            },
        autofillHints: widget.autofillHints,    
        style: const TextStyle(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          
          // Background Color
          filled: true,
          fillColor: Colors.grey[100],

          // Prefix Icon (Optional)
          prefixIcon: widget.icon != null 
              ? Icon(widget.icon, color: Colors.blueAccent) 
              : null,

          // Suffix Icon (Only for passwords)
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,

          // Border when the field is NOT focused
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),

          // Border when the field IS focused (User is typing)
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),

          // Border when validation fails (Error state)
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }
}