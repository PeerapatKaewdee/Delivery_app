import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:delivery_app/config/config.dart';
import 'package:flutter/material.dart';
import 'package:delivery_app/page/Login.dart';
import 'package:delivery_app/page/RegisterRider.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart'
    as http; // import 'package:latlong2/latlong.dart';

class RegisterCustomer extends StatefulWidget {
  const RegisterCustomer({super.key});

  @override
  State<RegisterCustomer> createState() => _RegisterCustomerState();
}

class _RegisterCustomerState extends State<RegisterCustomer> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameCtl = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? image;

  final TextEditingController addressController = TextEditingController();
  LatLng? selectedPosition;
  GoogleMapController? mapController;
  bool isLoadingLocation = true;
  final TextEditingController _addressController = TextEditingController();
  String debug = '';
  Future<LatLng> _getCurrentLocation() async {
    // ตรวจสอบและขอสิทธิ์การเข้าถึงตำแหน่ง
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position currentPosition = await Geolocator.getCurrentPosition();
    return LatLng(currentPosition.latitude, currentPosition.longitude);
  }

  @override
  void initState() {
    super.initState();
    // เรียกฟังก์ชันนี้ใน initState เพื่อดึงตำแหน่งปัจจุบัน
    _getCurrentLocation().then((position) {
      setState(() {
        selectedPosition = position;
        isLoadingLocation = false;
      });
    }).catchError((error) {
      print("Error getting location: $error");
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // ฟังก์ชันเรียกใช้ Google Places
  void autoCompleteSearch(String value) {
    // ตรวจสอบว่ากำหนด Google API Key หรือยัง
    String apiKey = 'YOUR_GOOGLE_API_KEY'; // ใส่ API Key ของคุณที่นี่
    if (apiKey.isEmpty) {
      log('API Key is missing!');
      return;
    }
  }

  // ฟังก์ชันตรวจสอบข้อมูลก่อนส่ง
  void check() async {
    log('message12');
    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    if (phoneController.text != '') {
      if (passwordController.text != '' ||
          confirmPasswordController.text != '') {
        if (passwordController.text == confirmPasswordController.text) {
          http.get(Uri.parse("$url/")).then((value) => {log(value.toString())});
          log('3');
          log('33');
        } else {
          log('password invalid.');
          _showErrorDialog('Password does not match!');
        }
      } else {
        log('Password is null');
        _showErrorDialog('Input password');
      }
    } else {
      log('Phone number is empty');
      _showErrorDialog('Input Phonenumber');
    }
  }

  // ฟังก์ชันแสดง Error Dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 330.0, // Adjust maximum width of the card
            ),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Custom logo icon
                Icon(
                  Icons.person,
                  size: 100,
                  color: Color.fromARGB(255, 144, 144, 144),
                ),
                Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.only(
                          top: 100.0), // Margin from top for the card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      elevation: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.all(
                            20.0), // Padding inside the card
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10.0),
                            Center(
                              child: GestureDetector(
                                onTap: () async {
                                  final XFile? pickedImage = await picker
                                      .pickImage(source: ImageSource.gallery);
                                  if (pickedImage != null) {
                                    log(pickedImage.path);
                                    setState(() {
                                      image =
                                          pickedImage; // อัปเดตค่า image ที่เลือก
                                    });
                                  } else {
                                    log('No Image');
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 45, // ขนาดของ avatar
                                  backgroundColor: Colors.grey[300],
                                  child: image !=
                                          null // ถ้า image มีค่า ให้แสดงรูปที่เลือกแทนไอคอน
                                      ? ClipOval(
                                          child: Image.file(
                                            File(image!.path),
                                            fit: BoxFit.cover,
                                            width: 90,
                                            height: 90,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 40, // ขนาดไอคอน
                                          color: Colors.white,
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Username',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: nameCtl,
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              // keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 10.0), // Spacing
                            const Text(
                              'Phone',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: phoneController,
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 10.0), // Spacing
                            // const Text(
                            //   'Adress',
                            //   style: TextStyle(fontWeight: FontWeight.bold),
                            // ),
                            isLoadingLocation
                                ? const CircularProgressIndicator() // แสดงการโหลดขณะรอการดึงตำแหน่ง
                                : SingleChildScrollView(
                                    child: Column(children: [
                                    TextField(
                                      controller: addressController,
                                      readOnly: true, // ปิดการพิมพ์
                                      decoration: const InputDecoration(
                                        hintText: 'Select location from map',
                                        isDense: true,
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 10.0,
                                          horizontal: 8.0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onTap: () async {
                                        LatLng? result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                SelectLocationMap(
                                              initialPosition:
                                                  selectedPosition!,
                                            ),
                                          ),
                                        );

                                        if (result != null) {
                                          setState(() {
                                            selectedPosition = result;
                                            addressController.text =
                                                'Lat: ${result.latitude}, Lng: ${result.longitude}';
                                          });
                                        }
                                      },
                                    ),
                                  ])),
                            const SizedBox(height: 10.0),
                            const Text(
                              'Address',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: _addressController,
                              style: const TextStyle(fontSize: 14.0),
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              // ใช้ Google Places สำหรับ AutoComplete
                              onChanged: (value) {
                                setState(() {
                                  autoCompleteSearch(value);
                                });
                              },
                            ),
                            const SizedBox(height: 10.0), // Spacing
                            const Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: passwordController,
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                              // keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 10.0), // Spacing
                            const Text(
                              'Confirm Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 5.0),
                            TextField(
                              controller: confirmPasswordController,
                              style:
                                  const TextStyle(fontSize: 14.0), // Font size
                              decoration: const InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 8.0,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15.0)),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              obscureText: true,
                              // keyboardType: TextInputType.number,
                            ),
                            // Text(debug),
                            const SizedBox(height: 20.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment
                                  .spaceBetween, // Arrange buttons with space in between
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .popUntil((route) => route.isFirst);
                                    // Handle back action
                                    // Navigate back to the previous screen
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                      const Color.fromARGB(255, 255, 255,
                                          255), // Color of the back button
                                    ),
                                    foregroundColor:
                                        WidgetStateProperty.all<Color>(
                                      const Color.fromRGBO(0, 253, 21, 0.62),
                                    ),
                                    elevation:
                                        WidgetStateProperty.all<double>(5.0),
                                    shape:
                                        WidgetStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Round corners of button
                                      ),
                                    ),
                                  ),
                                  child: const Text('Back'),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    _check();
                                    // Handle register action
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all<Color>(
                                      const Color.fromARGB(255, 1, 255, 98),
                                    ),
                                    foregroundColor:
                                        WidgetStateProperty.all<Color>(
                                      const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    elevation:
                                        WidgetStateProperty.all<double>(5.0),
                                    shape:
                                        WidgetStateProperty.all<OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            15.0), // Round corners of button
                                      ),
                                    ),
                                  ),
                                  child: const Text('Register'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 60,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RegisterRider(),
                                  ));
                            },
                            child: Text("Create Acount Rider -->"),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _check() async {
    log('message12');
    // แยกข้อมูล Lat และ Lng จาก addressController
    String extractLat(String text) {
      final latRegex = RegExp(r'Lat: ([\d\.\-]+)');
      return latRegex.firstMatch(text)?.group(1) ?? '0.0';
    }

    String extractLng(String text) {
      final lngRegex = RegExp(r'Lng: ([\d\.\-]+)');
      return lngRegex.firstMatch(text)?.group(1) ?? '0.0';
    }

    final String latitude = extractLat(addressController.text); // ดึงค่า Lat
    final String longitude = extractLng(addressController.text); // ดึงค่า Lng
    final String pointFormat =
        'POINT($longitude $latitude)'; // รูปแบบที่คุณต้องการ POINT(longitude latitude)

    var config = await Configuration.getConfig();
    var url = config['apiEndpoint'];
    if (nameCtl.text != '') {
      if (phoneController.text != '') {
        if (addressController.text != '') {
          if (passwordController.text != '' ||
              confirmPasswordController.text != '') {
            if (passwordController.text == confirmPasswordController.text) {
              http
                  .post(
                Uri.parse("$url/api/user/register"),
                headers: {"Content-Type": "application/json; charset=utf-8"},
                body: jsonEncode({
                  'phone_number': phoneController.text,
                  'password': passwordController.text,
                  'name': nameCtl.text,
                  'profile_image': '',
                  'address': '',
                  'gps_location': pointFormat
                }),
              )
                  .then((value) {
                log('message123');
                log(addressController.text);
                log(value.body.toString());
                var jsonResponse = jsonDecode(value.body);
                if (value.statusCode == 200 ||
                    jsonResponse['message'] == "ลงทะเบียนผู้ใช้สำเร็จ") {
                  // Registration successful
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Success'),
                      content: Text('User registered successfully!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).popUntil(
                              (route) => route.isFirst,
                            );
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else if (value.statusCode == 409) {
                  // Phone number already exists
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error!!!'),
                      content: Text('Phone number already exists.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Some other error
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content:
                          Text('Failed to register user. Please try again.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
                log(value.body.toString());
                log('registeUser');
              });
            } else {
              log('password invalid.');
              setState(() {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Error!!!!'),
                    content: Text('Password does not match!!!!'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('OK'),
                      ),
                    ],
                  ),
                );
              });
            }
          } else {
            log('4');
            setState(() {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Error!!!!'),
                  content: Text('Password is null ,input password'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            });
          }
        } else {
          log(phoneController.text);
          log('2');
          setState(() {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Error !!!'),
                content: Text('Input Address or selete Address !!!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          });
        }
      } else {
        setState(() {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error !!!'),
              content: Text('Input PhoneNumber !!!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            ),
          );
        });
      }
    } else {
      setState(() {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Error !!!'),
            content: Text('Input Username !!!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }
}

class SelectLocationMap extends StatefulWidget {
  final LatLng initialPosition;

  const SelectLocationMap({super.key, required this.initialPosition});

  @override
  State<SelectLocationMap> createState() => _SelectLocationMapState();
}

class _SelectLocationMapState extends State<SelectLocationMap> {
  LatLng? selectedPosition;
  GoogleMapController? _mapController;
  LatLng? currentLocation;
  // LatLng latLng = const LatLng(16.246825669508297, 103.25199289277295);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    // ตรวจสอบและขอสิทธิ์การเข้าถึงตำแหน่ง
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    // ดึงตำแหน่งปัจจุบัน
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
      selectedPosition = currentLocation;
    });

    // ย้ายกล้องไปที่ตำแหน่งปัจจุบัน
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(currentLocation!),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(currentLocation!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(context, selectedPosition);
            },
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(
              child: CircularProgressIndicator()) // โหลดตำแหน่งปัจจุบัน
          : GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.initialPosition ??
                    currentLocation!, // ถ้ามีตำแหน่งจาก widget ให้ใช้, ถ้าไม่มีก็ใช้ตำแหน่งปัจจุบัน
                zoom: 15.0,
              ),
              onTap: (LatLng position) {
                setState(() {
                  selectedPosition = position;
                });
              },
              markers: selectedPosition != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selected_location'),
                        position: selectedPosition!,
                      ),
                    }
                  : {},
            ),
    );
  }
}
