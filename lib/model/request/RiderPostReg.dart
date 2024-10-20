// To parse this JSON data, do
//
//     final riderPostReg = riderPostRegFromJson(jsonString);

import 'dart:convert';

RiderPostReg riderPostRegFromJson(String str) => RiderPostReg.fromJson(json.decode(str));

String riderPostRegToJson(RiderPostReg data) => json.encode(data.toJson());

class RiderPostReg {
    String phoneNumber;
    String password;
    String name;
    String profileImage;
    String licensePlate;

    RiderPostReg({
        required this.phoneNumber,
        required this.password,
        required this.name,
        required this.profileImage,
        required this.licensePlate,
    });

    factory RiderPostReg.fromJson(Map<String, dynamic> json) => RiderPostReg(
        phoneNumber: json["phone_number"],
        password: json["password"],
        name: json["name"],
        profileImage: json["profile_image"],
        licensePlate: json["license_plate"],
    );

    Map<String, dynamic> toJson() => {
        "phone_number": phoneNumber,
        "password": password,
        "name": name,
        "profile_image": profileImage,
        "license_plate": licensePlate,
    };
}
