import 'package:flutter/material.dart';

// ── Colors ──────────────────────────────────────────────
const kPrimaryColor    = Color(0xFFFF6B35); // vibrant orange-red
const kSecondaryColor  = Color(0xFF1A1A2E); // deep navy
const kAccentColor     = Color(0xFFFFD700); // gold accent
const kBackgroundColor = Color(0xFFF8F9FA);
const kCardColor       = Color(0xFFFFFFFF);
const kTextColor       = Color(0xFF1A1A2E);
const kSubTextColor    = Color(0xFF6B7280);
const kBorderColor     = Color(0xFFE5E7EB);
const kErrorColor      = Color(0xFFEF4444);
const kSuccessColor    = Color(0xFF10B981);

// ── Spacing ─────────────────────────────────────────────
const kDefaultPadding  = 20.0;
const kSmallPadding    = 10.0;
const kLargePadding    = 32.0;

// ── Validation messages ──────────────────────────────────
const kPhoneNullError      = "Please enter your phone number";
const kInvalidPhoneError   = "Please enter a valid Algerian phone number";
const kFirstNameNullError  = "Please enter your first name";
const kLastNameNullError   = "Please enter your family name";
const kEmailInvalidError   = "Please enter a valid email";
const kRestaurantNullError = "Please enter your restaurant name";
const kAddressNullError    = "Please enter your address";
const kOtpNullError        = "Please enter the complete OTP code";

// ── API ──────────────────────────────────────────────────
const kBaseUrl = "http://10.0.2.2:3000/api"; // Android emulator localhost
// const kBaseUrl = "http://localhost:3000/api"; // iOS simulator

// ── Storage Keys ─────────────────────────────────────────
const kTokenKey      = "merchant_token";
const kMerchantKey   = "merchant_data";