import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

const String backendBaseUrl = 'http://10.52.110.158:5000';

String currentUserDisplayName() {
  final user = FirebaseAuth.instance.currentUser;
  final displayName = user?.displayName?.trim();

  if (displayName != null && displayName.isNotEmpty) {
    return displayName;
  }

  final email = user?.email?.trim();
  if (email != null && email.isNotEmpty && email.contains('@')) {
    final prefix = email.split('@').first.trim();
    if (prefix.isNotEmpty) return prefix;
  }

  return 'User';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MrCoolieApp());
}
// ============================================================
// APP
// ============================================================

class MrCoolieApp extends StatelessWidget {
  const MrCoolieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mr. கூலி',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F4EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF28C28),
          primary: const Color(0xFFF28C28),
        ),
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

const Color navy = Color(0xFF102A43);
const Color darkNavy = Color(0xFF0B1F33);
const Color orange = Color(0xFFF28C28);
const Color cream = Color(0xFFF8F4EC);
const Color lightOrange = Color(0xFFFFE8CC);
const Color green = Color(0xFF2E7D32);
const Color red = Color(0xFFC62828);
const Color greyText = Color(0xFF667085);

// ============================================================
// DATA
// ============================================================

final List<Map<String, dynamic>> departments = [
  {
    'name': 'Construction & Civil',
    'icon': Icons.construction,
    'skills': [
      'Mason',
      'Construction Helper',
      'Shuttering Worker',
      'Bar Bender',
      'Tile Worker',
      'Concrete Worker'
    ]
  },
  {
    'name': 'Electrical',
    'icon': Icons.electrical_services,
    'skills': [
      'Electrician',
      'Wireman',
      'Electrical Technician',
      'Electrical Helper',
      'Motor Technician'
    ]
  },
  {
    'name': 'Plumbing & Sanitary',
    'icon': Icons.plumbing,
    'skills': [
      'Plumber',
      'Pipe Fitter',
      'Bathroom Fitting Worker',
      'Water Tank Worker'
    ]
  },
  {
    'name': 'Carpentry & Wood Work',
    'icon': Icons.handyman,
    'skills': [
      'Carpenter',
      'Furniture Worker',
      'Door/Window Worker',
      'Wood Polishing Worker'
    ]
  },
  {
    'name': 'Metal / Iron Work',
    'icon': Icons.hardware,
    'skills': [
      'Iron Worker',
      'Welder',
      'Grill Worker',
      'Gate Worker',
      'Steel Fabricator',
      'Sheet Metal Worker'
    ]
  },
  {
    'name': 'Agriculture / Farming',
    'icon': Icons.agriculture,
    'skills': [
      'Farm Worker',
      'Harvesting Worker',
      'Irrigation Worker',
      'Tractor Operator',
      'Agricultural Machine Operator',
      'Field Worker'
    ]
  },
  {
    'name': 'Automobile',
    'icon': Icons.car_repair,
    'skills': [
      'Two-Wheeler Mechanic',
      'Auto Mechanic',
      'Tyre Worker',
      'Battery Technician',
      'Vehicle Washing Worker'
    ]
  },
  {
    'name': 'Home Services',
    'icon': Icons.home_repair_service,
    'skills': [
      'House Cleaner',
      'Cook',
      'Gardener',
      'Ironing Worker',
      'Home Maintenance Worker'
    ]
  },
  {
    'name': 'Cleaning & Maintenance',
    'icon': Icons.cleaning_services,
    'skills': [
      'House Cleaner',
      'Office Cleaner',
      'Shop Cleaner',
      'Building Maintenance Worker'
    ]
  },
  {
    'name': 'Shops & Commercial',
    'icon': Icons.store,
    'skills': [
      'Shop Helper',
      'Sales Assistant',
      'Billing Assistant',
      'Stock Worker',
      'Packing Worker'
    ]
  },
  {
    'name': 'Hotel / Food Services',
    'icon': Icons.restaurant,
    'skills': [
      'Cook',
      'Kitchen Helper',
      'Server',
      'Catering Worker',
      'Tea/Coffee Worker'
    ]
  },
  {
    'name': 'Transport / Loading',
    'icon': Icons.local_shipping,
    'skills': [
      'Loading Worker',
      'Unloading Worker',
      'Lorry Helper',
      'Delivery Worker',
      'Warehouse Worker'
    ]
  },
  {
    'name': 'Printing / Offset',
    'icon': Icons.print,
    'skills': [
      'Offset Machine Operator',
      'Printing Helper',
      'Binding Worker',
      'Cutting Worker',
      'Printing Packing Worker'
    ]
  },
  {
    'name': 'Packaging',
    'icon': Icons.inventory_2,
    'skills': [
      'Packing Worker',
      'Labeling Worker',
      'Sorting Worker',
      'Warehouse Packing Worker'
    ]
  },
  {
    'name': 'Fireworks Industry',
    'icon': Icons.celebration,
    'skills': [
      'Production Worker',
      'Packing Worker',
      'Quality Worker',
      'General Factory Worker'
    ]
  },
  {
    'name': 'Match Industry',
    'icon': Icons.factory,
    'skills': [
      'Production Worker',
      'Packing Worker',
      'Machine Operator',
      'Quality Worker'
    ]
  },
  {
    'name': 'Tailoring & Clothing',
    'icon': Icons.checkroom,
    'skills': [
      'Tailor',
      'Stitching Worker',
      'Embroidery Worker',
      'Cutting Worker',
      'Alteration Worker'
    ]
  },
  {
    'name': 'Electronics / Mobile',
    'icon': Icons.phone_android,
    'skills': [
      'Mobile Technician',
      'Electronics Repair Worker',
      'TV Repair Worker',
      'Computer Technician',
      'CCTV Technician'
    ]
  },
  {
    'name': 'Gardening & Outdoor',
    'icon': Icons.grass,
    'skills': [
      'Gardener',
      'Tree Worker',
      'Grass Cutting Worker',
      'Landscaping Worker',
      'Garden Maintenance Worker'
    ]
  },
  {
    'name': 'General Local Services',
    'icon': Icons.people,
    'skills': [
      'General Helper',
      'Daily Wage Worker',
      'Event Helper',
      'Moving Helper',
      'Temporary Worker'
    ]
  },
];

final List<Map<String, dynamic>> demoJobs = [
  {
    'title': 'House Wiring Work',
    'department': 'Electrical',
    'skill': 'Electrician',
    'location': 'Sivakasi',
    'payment': 800,
    'duration': '1 Day',
    'employer': 'Ravi',
    'description': 'Need an electrician for house wiring and switch installation.',
  },
  {
    'title': 'House Construction Helper',
    'department': 'Construction & Civil',
    'skill': 'Construction Helper',
    'location': 'Virudhunagar',
    'payment': 700,
    'duration': '1 Day',
    'employer': 'Kumar',
    'description': 'Construction helper required for residential building work.',
  },
  {
    'title': 'Farm Harvesting Worker',
    'department': 'Agriculture / Farming',
    'skill': 'Harvesting Worker',
    'location': 'Sattur',
    'payment': 900,
    'duration': '2 Days',
    'employer': 'Selvam',
    'description': 'Workers required for harvesting and field activities.',
  },
  {
    'title': 'Plumbing Repair',
    'department': 'Plumbing & Sanitary',
    'skill': 'Plumber',
    'location': 'Sivakasi',
    'payment': 750,
    'duration': '1 Day',
    'employer': 'Arun',
    'description': 'Bathroom and pipeline repair work.',
  },
  {
    'title': 'Offset Printing Helper',
    'department': 'Printing / Offset',
    'skill': 'Printing Helper',
    'location': 'Sivakasi',
    'payment': 650,
    'duration': '1 Day',
    'employer': 'Prakash',
    'description': 'Helper required for offset printing and packing.',
  },
];

// ============================================================
// LOGIN / FIREBASE AUTHENTICATION
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? verificationId;
  bool isSubmitting = false;
  bool showPhoneLogin = true;
  bool showOtpField = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _normalisePhone(String value) {
    var phone = value.trim().replaceAll(' ', '');

    if (phone.startsWith('0')) {
      phone = '+91${phone.substring(1)}';
    } else if (RegExp(r'^\d{10}$').hasMatch(phone)) {
      phone = '+91$phone';
    }

    return phone;
  }

  bool _isValidPhone(String phone) {
    return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone);
  }

  void _goHome() {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (route) => false,
    );
  }

  Future<void> _sendOtp() async {
    final phone = _normalisePhone(phoneController.text);

    if (!_isValidPhone(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a valid phone number with country code.'),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,

        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) {
              setState(() {
                showOtpField = false;
                isSubmitting = false;
              });
              _goHome();
            }
          } on FirebaseAuthException catch (e) {
            if (mounted) {
              setState(() => isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_firebaseError(e))),
              );
            }
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() => isSubmitting = false);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_firebaseError(e))),
          );
        },

        codeSent: (String id, int? resendToken) {
          if (!mounted) return;

          setState(() {
            verificationId = id;
            showOtpField = true;
            isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent successfully. Check your SMS.'),
            ),
          );
        },

        codeAutoRetrievalTimeout: (String id) {
          verificationId = id;
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start phone verification: $e')),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final id = verificationId;
    final otp = otpController.text.trim();

    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please request OTP first.')),
      );
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP.')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: otp,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      setState(() => isSubmitting = false);
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_firebaseError(e))),
      );
    }
  }

  Future<void> _loginWithEmail() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter email and password.')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      setState(() => isSubmitting = false);
      _goHome();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_firebaseError(e))),
      );
    }
  }

  Future<void> _forgotPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email first.')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_firebaseError(e))),
      );
    }
  }

  String _firebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Use the full country code.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'invalid-verification-code':
        return 'Incorrect OTP. Please check the SMS and try again.';
      case 'session-expired':
        return 'OTP expired. Please request a new OTP.';
      case 'invalid-credential':
        return 'The login details are invalid.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-login-credentials':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 35),

              Container(
                height: 90,
                width: 90,
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.handyman,
                  size: 48,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Mr. கூலி',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Work • Earn • Grow',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Login to continue',
                      style: TextStyle(color: greyText),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('📱 Phone OTP'),
                            selected: showPhoneLogin,
                            onSelected: isSubmitting
                                ? null
                                : (_) {
                                    setState(() {
                                      showPhoneLogin = true;
                                      showOtpField = false;
                                    });
                                  },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text('📧 Email'),
                            selected: !showPhoneLogin,
                            onSelected: isSubmitting
                                ? null
                                : (_) {
                                    setState(() {
                                      showPhoneLogin = false;
                                    });
                                  },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (showPhoneLogin) ...[
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          hintText: '+91 9876543210',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (showOtpField)
                        TextField(
                          controller: otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          enabled: !isSubmitting,
                          decoration: InputDecoration(
                            labelText: '6-digit OTP',
                            prefixIcon: const Icon(Icons.sms_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : showOtpField
                                  ? _verifyOtp
                                  : _sendOtp,
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  showOtpField
                                      ? 'VERIFY & LOGIN'
                                      : 'SEND OTP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),

                      if (showOtpField)
                        Center(
                          child: TextButton(
                            onPressed: isSubmitting ? null : _sendOtp,
                            child: const Text('Resend OTP'),
                          ),
                        ),
                    ] else ...[
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        enabled: !isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: isSubmitting ? null : _forgotPassword,
                          child: const Text('Forgot Password?'),
                        ),
                      ),

                      const SizedBox(height: 5),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: orange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed:
                              isSubmitting ? null : _loginWithEmail,
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 15),

                    Center(
                      child: TextButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RegisterScreen(),
                                  ),
                                );
                              },
                        child: const Text(
                          'New user? Create Account',
                          style: TextStyle(color: navy),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER WITH FIREBASE EMAIL/PASSWORD
// ============================================================

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final locationController = TextEditingController();

  String selectedRole = 'worker';
  bool isSubmitting = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    locationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final location = locationController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields.'),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password should be at least 6 characters.'),
        ),
      );
      return;
    }

    if (selectedRole == 'worker' && location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is required for workers.'),
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      if (!mounted) return;

      setState(() => isSubmitting = false);

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Account Created'),
          content: const Text(
            'Your Firebase account was created successfully. '
            'You can now continue to Mr. கூலி.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_firebaseRegisterError(e))),
      );
    }
  }

  String _firebaseRegisterError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled in Firebase.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            const Icon(
              Icons.person_add,
              size: 70,
              color: orange,
            ),

            const SizedBox(height: 15),

            const Text(
              'Join Mr. கூலி',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: nameController,
              enabled: !isSubmitting,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              enabled: !isSubmitting,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: InputDecoration(
                labelText: 'Account Type',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'worker',
                  child: Text('Worker'),
                ),
                DropdownMenuItem(
                  value: 'employer',
                  child: Text('Employer'),
                ),
              ],
              onChanged: isSubmitting
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => selectedRole = value);
                      }
                    },
            ),

            if (selectedRole == 'worker') ...[
              const SizedBox(height: 16),
              TextField(
                controller: locationController,
                enabled: !isSubmitting,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Location',
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              enabled: !isSubmitting,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: confirmPasswordController,
              enabled: !isSubmitting,
              obscureText: obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      obscureConfirmPassword =
                          !obscureConfirmPassword;
                    });
                  },
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: isSubmitting ? null : _register,
                child: isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'CREATE ACCOUNT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: isSubmitting
                  ? null
                  : () => Navigator.pop(context),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int selectedIndex = 0;

  final screens = const [
    HomeScreen(),
    FindWorkScreen(),
    DepartmentsScreen(),
    FinanceScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        backgroundColor: Colors.white,
        indicatorColor: lightOrange,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Find Work',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Departments',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Finance',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mr. கூலி',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vanakkam, ${currentUserDisplayName()} 👋',
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Find work. Earn money. Build your future.',
              style: TextStyle(color: greyText),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    context,
                    Icons.search,
                    'Find Work',
                    'Find nearby jobs',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FindWorkScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionCard(
                    context,
                    Icons.person_search,
                    'Need Worker',
                    'Post a job',
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PostJobScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _earningsCard(context),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Jobs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FindWorkScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),

            ...demoJobs.take(3).map(
                  (job) => JobCard(
                    job: job,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailsScreen(job: job),
                        ),
                      );
                    },
                  ),
                ),

            const SizedBox(height: 20),

            const Text(
              'Popular Departments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 115,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  final department = departments[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DepartmentDetailScreen(
                            department: department,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.black12,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            department['icon'],
                            color: orange,
                            size: 35,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            department['name'],
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Icon(
              icon,
              color: orange,
              size: 35,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _earningsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            navy,
            Color(0xFF1E4668),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week Earnings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '₹4,800',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 6),
              const Text(
                '+18% from last week',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FinanceScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Finance',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FIND WORK
// ============================================================

class FindWorkScreen extends StatefulWidget {
  const FindWorkScreen({super.key});

  @override
  State<FindWorkScreen> createState() => _FindWorkScreenState();
}

class _FindWorkScreenState extends State<FindWorkScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final filteredJobs = demoJobs.where((job) {
      final text =
          '${job['title']} ${job['department']} ${job['skill']} ${job['location']}'
              .toLowerCase();

      return text.contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Find Work'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search jobs, skills or location',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: filteredJobs.isEmpty
                ? const Center(
                    child: Text(
                      'No jobs found',
                      style: TextStyle(
                        fontSize: 18,
                        color: greyText,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];

                      return JobCard(
                        job: job,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  JobDetailsScreen(job: job),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// JOB CARD
// ============================================================

class JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.work,
                      color: orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      job['title'],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: navy,
                      ),
                    ),
                  ),
                  Text(
                    '₹${job['payment']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                job['skill'],
                style: const TextStyle(
                  color: greyText,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: greyText,
                  ),
                  const SizedBox(width: 4),
                  Text(job['location']),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.schedule,
                    size: 18,
                    color: greyText,
                  ),
                  const SizedBox(width: 4),
                  Text(job['duration']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// JOB DETAILS
// ============================================================

class JobDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobDetailsScreen({
    super.key,
    required this.job,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Job Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.work,
                    color: orange,
                    size: 45,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    job['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    job['department'],
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _detailRow(
              Icons.person,
              'Employer',
              job['employer'],
            ),

            _detailRow(
              Icons.location_on,
              'Location',
              job['location'],
            ),

            _detailRow(
              Icons.work_outline,
              'Required Skill',
              job['skill'],
            ),

            _detailRow(
              Icons.schedule,
              'Duration',
              job['duration'],
            ),

            _detailRow(
              Icons.currency_rupee,
              'Payment',
              '₹${job['payment']}',
            ),

            const SizedBox(height: 20),

            const Text(
              'Job Description',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              job['description'],
              style: const TextStyle(
                color: greyText,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.send),
                label: const Text(
                  'APPLY FOR THIS JOB',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Application Sent'),
                      content: const Text(
                        'Your application has been sent to the employer.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(
            icon,
            color: orange,
          ),
          const SizedBox(width: 12),
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: greyText),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DEPARTMENTS
// ============================================================

class DepartmentsScreen extends StatelessWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Departments'),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
        ),
        itemBuilder: (context, index) {
          final department = departments[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DepartmentDetailScreen(
                    department: department,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.black12,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      department['icon'],
                      color: orange,
                      size: 32,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    department['name'],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: navy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${department['skills'].length} skills',
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// DEPARTMENT DETAILS
// ============================================================

class DepartmentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> department;

  const DepartmentDetailScreen({
    super.key,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    final List skills = department['skills'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: Text(department['name']),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: lightOrange,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                skills[index],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: navy,
                ),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// POST JOB
// ============================================================

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final locationController = TextEditingController();
  final paymentController = TextEditingController();

  String? selectedDepartment;
  String? selectedSkill;
  String selectedDuration = '1 Day';

  List<String> get skills {
    final department = departments.firstWhere(
      (item) => item['name'] == selectedDepartment,
      orElse: () => {'skills': <String>[]},
    );

    return List<String>.from(department['skills']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Need a Worker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post a Job',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'Find the right worker for your work.',
              style: TextStyle(color: greyText),
            ),

            const SizedBox(height: 25),

            _label('Job Title'),

            TextField(
              controller: titleController,
              decoration: _inputDecoration(
                'Example: House Wiring',
                Icons.work,
              ),
            ),

            const SizedBox(height: 18),

            _label('Department'),

            DropdownButtonFormField<String>(
              initialValue: selectedDepartment,
              decoration: _inputDecoration(
                'Select Department',
                Icons.category,
              ),
              items: departments.map((department) {
                return DropdownMenuItem<String>(
                  value: department['name'],
                  child: Text(department['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                  selectedSkill = null;
                });
              },
            ),

            const SizedBox(height: 18),

            _label('Required Skill'),

            DropdownButtonFormField<String>(
              initialValue: selectedSkill,
              decoration: _inputDecoration(
                'Select Skill',
                Icons.handyman,
              ),
              items: skills.map((skill) {
                return DropdownMenuItem<String>(
                  value: skill,
                  child: Text(skill),
                );
              }).toList(),
              onChanged: selectedDepartment == null
                  ? null
                  : (value) {
                      setState(() {
                        selectedSkill = value;
                      });
                    },
            ),

            const SizedBox(height: 18),

            _label('Job Description'),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: _inputDecoration(
                'Describe the work...',
                Icons.description,
              ),
            ),

            const SizedBox(height: 18),

            _label('Location'),

            TextField(
              controller: locationController,
              decoration: _inputDecoration(
                'Example: Sivakasi',
                Icons.location_on,
              ),
            ),

            const SizedBox(height: 18),

            _label('Payment'),

            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration(
                'Example: ₹700',
                Icons.currency_rupee,
              ),
            ),

            const SizedBox(height: 18),

            _label('Duration'),

            DropdownButtonFormField<String>(
              initialValue: selectedDuration,
              decoration: _inputDecoration(
                'Select Duration',
                Icons.schedule,
              ),
              items: const [
                DropdownMenuItem(
                  value: '1 Day',
                  child: Text('1 Day'),
                ),
                DropdownMenuItem(
                  value: '2 Days',
                  child: Text('2 Days'),
                ),
                DropdownMenuItem(
                  value: '3 Days',
                  child: Text('3 Days'),
                ),
                DropdownMenuItem(
                  value: '1 Week',
                  child: Text('1 Week'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDuration = value ?? '1 Day';
                });
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  if (titleController.text.isEmpty ||
                      selectedDepartment == null ||
                      selectedSkill == null ||
                      locationController.text.isEmpty ||
                      paymentController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please fill all required fields.',
                        ),
                      ),
                    );
                    return;
                  }

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Job Posted Successfully'),
                      content: const Text(
                        'Workers can now view and apply for your job.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('DONE'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text(
                  'POST JOB',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: navy,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

// ============================================================
// FINANCE
// ============================================================

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('My Finance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _financeBalance(),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _financeSmallCard(
                    'This Week',
                    '₹4,800',
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _financeSmallCard(
                    'Jobs',
                    '24',
                    Icons.work,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            const Text(
              'Quick Finance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),

            const SizedBox(height: 12),

            _financeAction(
              context,
              Icons.receipt_long,
              'Transactions',
              'View your payment history',
              const TransactionsScreen(),
            ),

            _financeAction(
              context,
              Icons.savings,
              'Savings Goals',
              'Save money for your goals',
              const SavingsScreen(),
            ),

            _financeAction(
              context,
              Icons.auto_awesome,
              'AI Financial Insights',
              'Understand your earnings',
              const AIInsightsScreen(),
            ),

            _financeAction(
              context,
              Icons.badge,
              'Digital Work ID',
              'Your verified work identity',
              const DigitalWorkIDScreen(),
            ),

            _financeAction(
              context,
              Icons.payment,
              'Digital Payment Demo',
              'Try a simulated payment',
              const PaymentDemoScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _financeBalance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '₹18,500',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '24 completed jobs',
            style: TextStyle(
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _financeSmallCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: orange,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: greyText,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _financeAction(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget page,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: CircleAvatar(
          backgroundColor: lightOrange,
          child: Icon(
            icon,
            color: orange,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => page,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// TRANSACTIONS
// ============================================================

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final transactions = [
      ['Electrical Wiring', '₹700', '24 Sep 2026'],
      ['House Construction', '₹900', '22 Sep 2026'],
      ['Farm Work', '₹1,200', '20 Sep 2026'],
      ['Plumbing Repair', '₹750', '18 Sep 2026'],
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Transactions'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: lightOrange,
                child: Icon(
                  Icons.arrow_downward,
                  color: green,
                ),
              ),
              title: Text(
                transaction[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              subtitle: Text(transaction[2]),
              trailing: Text(
                '+${transaction[1]}',
                style: const TextStyle(
                  color: green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SAVINGS
// ============================================================

class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Savings Goals'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _goalCard(
            'Buy New Tools',
            10000,
            6500,
            Icons.build,
          ),
          _goalCard(
            'Emergency Fund',
            15000,
            7200,
            Icons.health_and_safety,
          ),
          _goalCard(
            'New Mobile Phone',
            20000,
            8500,
            Icons.phone_android,
          ),
        ],
      ),
    );
  }

  Widget _goalCard(
    String title,
    double target,
    double saved,
    IconData icon,
  ) {
    final progress = saved / target;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: lightOrange,
                  child: Icon(
                    icon,
                    color: orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              borderRadius: BorderRadius.circular(10),
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved ₹${saved.toInt()}',
                  style: const TextStyle(
                    color: greyText,
                  ),
                ),
                Text(
                  'Target ₹${target.toInt()}',
                  style: const TextStyle(
                    color: greyText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// AI INSIGHTS
// ============================================================

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('AI Financial Insights'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: orange,
                    size: 40,
                  ),
                  SizedBox(height: 15),
                  Text(
                    'Your Financial Insight',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI-based insights from your work and earnings history.',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _insight(
              Icons.trending_up,
              'Earnings Growth',
              'Your earnings increased from ₹15,200 to ₹18,500 compared with last month.',
            ),

            _insight(
              Icons.star,
              'Top Earning Category',
              'Electrical work is currently your highest earning category.',
            ),

            _insight(
              Icons.savings,
              'Savings Suggestion',
              'Based on your recent earnings, you could target ₹2,000 monthly savings.',
            ),

            _insight(
              Icons.work_history,
              'Work Pattern',
              'You completed more jobs this month compared with the previous month.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _insight(
    IconData icon,
    String title,
    String text,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 13),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: lightOrange,
              child: Icon(
                icon,
                color: orange,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: navy,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    text,
                    style: const TextStyle(
                      color: greyText,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DIGITAL WORK ID
// ============================================================

class DigitalWorkIDScreen extends StatelessWidget {
  const DigitalWorkIDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Digital Work ID'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.verified,
                        color: orange,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'MR. கூலி WORK ID',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: orange,
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    currentUserDisplayName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    'Electrician',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _WorkStat(
                        value: '42',
                        label: 'Jobs',
                      ),
                      _WorkStat(
                        value: '38',
                        label: 'Verified',
                      ),
                      _WorkStat(
                        value: '4.7',
                        label: 'Rating',
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Container(
                    height: 100,
                    width: 100,
                    color: Colors.white,
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2,
                        size: 75,
                        color: navy,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Verified Work & Income History',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.check_circle,
                        color: green,
                      ),
                      title: Text('Work History'),
                      subtitle: Text('42 jobs completed'),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.verified,
                        color: green,
                      ),
                      title: Text('Verified Jobs'),
                      subtitle: Text('38 jobs verified'),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.account_balance_wallet,
                        color: green,
                      ),
                      title: Text('Earnings History'),
                      subtitle: Text('₹18,500 recorded earnings'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkStat extends StatelessWidget {
  final String value;
  final String label;

  const _WorkStat({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PAYMENT DEMO
// ============================================================

class PaymentDemoScreen extends StatefulWidget {
  const PaymentDemoScreen({super.key});

  @override
  State<PaymentDemoScreen> createState() => _PaymentDemoScreenState();
}

class _PaymentDemoScreenState extends State<PaymentDemoScreen> {
  bool paid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('Digital Payment Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.electrical_services,
                    size: 55,
                    color: orange,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Electrical Wiring',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Job Completed ✓',
                    style: TextStyle(
                      color: green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '₹700',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: navy,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            if (paid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: green,
                      size: 60,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Payment Successful',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: green,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Transaction ID: MRK-20260924-001',
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      paid = true;
                    });
                  },
                  child: const Text(
                    'PAY ₹700',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            const Text(
              'This is a prototype payment simulation for demonstration purposes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: navy,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: orange,
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUserDisplayName(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 5),
                      Text(
                        '4.7 Rating',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _profileItem(
              context,
              Icons.badge,
              'Digital Work ID',
              'View your verified work identity',
              const DigitalWorkIDScreen(),
            ),

            _profileItem(
              context,
              Icons.handyman,
              'My Skills',
              'Electrician, Wireman',
              null,
            ),

            _profileItem(
              context,
              Icons.history,
              'Work History',
              '42 completed jobs',
              null,
            ),

            _profileItem(
              context,
              Icons.star,
              'Ratings',
              '4.7 average rating',
              null,
            ),

            _profileItem(
              context,
              Icons.settings,
              'Settings',
              'Account and preferences',
              null,
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: red,
                  side: const BorderSide(color: red),
                  padding: const EdgeInsets.all(15),
                ),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logout failed: $e')),
                    );
                    return;
                  }

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('LOGOUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget? page,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lightOrange,
          child: Icon(
            icon,
            color: orange,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: navy,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: page == null
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => page,
                  ),
                );
              },
      ),
    );
  }
}

