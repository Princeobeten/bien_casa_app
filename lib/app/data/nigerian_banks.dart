class NigerianBanks {
  static const List<Map<String, dynamic>> banks = [
    {
      "name": "Access Bank",
      "slug": "access-bank",
      "code": "044",
      "logo": "https://nigerianbanks.xyz/logo/access-bank.png"
    },
    {
      "name": "Citibank Nigeria",
      "slug": "citibank-nigeria",
      "code": "023",
      "logo": "https://nigerianbanks.xyz/logo/citibank-nigeria.png"
    },
    {
      "name": "Ecobank Nigeria",
      "slug": "ecobank-nigeria",
      "code": "050",
      "logo": "https://nigerianbanks.xyz/logo/ecobank-nigeria.png"
    },
    {
      "name": "Fidelity Bank",
      "slug": "fidelity-bank",
      "code": "070",
      "logo": "https://nigerianbanks.xyz/logo/fidelity-bank.png"
    },
    {
      "name": "First Bank of Nigeria",
      "slug": "first-bank-of-nigeria",
      "code": "011",
      "logo": "https://nigerianbanks.xyz/logo/first-bank-of-nigeria.png"
    },
    {
      "name": "First City Monument Bank",
      "slug": "first-city-monument-bank",
      "code": "214",
      "logo": "https://nigerianbanks.xyz/logo/first-city-monument-bank.png"
    },
    {
      "name": "Guaranty Trust Bank",
      "slug": "guaranty-trust-bank",
      "code": "058",
      "logo": "https://nigerianbanks.xyz/logo/guaranty-trust-bank.png"
    },
    {
      "name": "Heritage Bank",
      "slug": "heritage-bank",
      "code": "030",
      "logo": "https://nigerianbanks.xyz/logo/heritage-bank.png"
    },
    {
      "name": "Keystone Bank",
      "slug": "keystone-bank",
      "code": "082",
      "logo": "https://nigerianbanks.xyz/logo/keystone-bank.png"
    },
    {
      "name": "Polaris Bank",
      "slug": "polaris-bank",
      "code": "076",
      "logo": "https://nigerianbanks.xyz/logo/polaris-bank.png"
    },
    {
      "name": "Stanbic IBTC Bank",
      "slug": "stanbic-ibtc-bank",
      "code": "221",
      "logo": "https://nigerianbanks.xyz/logo/stanbic-ibtc-bank.png"
    },
    {
      "name": "Standard Chartered Bank",
      "slug": "standard-chartered-bank",
      "code": "068",
      "logo": "https://nigerianbanks.xyz/logo/standard-chartered-bank.png"
    },
    {
      "name": "Sterling Bank",
      "slug": "sterling-bank",
      "code": "232",
      "logo": "https://nigerianbanks.xyz/logo/sterling-bank.png"
    },
    {
      "name": "Union Bank of Nigeria",
      "slug": "union-bank-of-nigeria",
      "code": "032",
      "logo": "https://nigerianbanks.xyz/logo/union-bank-of-nigeria.png"
    },
    {
      "name": "United Bank For Africa",
      "slug": "united-bank-for-africa",
      "code": "033",
      "logo": "https://nigerianbanks.xyz/logo/united-bank-for-africa.png"
    },
    {
      "name": "Unity Bank",
      "slug": "unity-bank",
      "code": "215",
      "logo": "https://nigerianbanks.xyz/logo/unity-bank.png"
    },
    {
      "name": "Wema Bank",
      "slug": "wema-bank",
      "code": "035",
      "logo": "https://nigerianbanks.xyz/logo/wema-bank.png"
    },
    {
      "name": "Zenith Bank",
      "slug": "zenith-bank",
      "code": "057",
      "logo": "https://nigerianbanks.xyz/logo/zenith-bank.png"
    },
    {
      "name": "OPAY DIGITAL SERVICES LIMITED",
      "slug": "paycom",
      "code": "999992",
      "logo": "https://nigerianbanks.xyz/logo/paycom.png"
    },
    {
      "name": "PalmPay",
      "slug": "palmpay",
      "code": "999991",
      "logo": "https://nigerianbanks.xyz/logo/palmpay.png"
    },
    {
      "name": "Moniepoint",
      "slug": "moniepoint",
      "code": "50515",
      "logo": "https://nigerianbanks.xyz/logo/moniepoint.png"
    },
    {
      "name": "Kuda Bank",
      "slug": "kuda-bank",
      "code": "50211",
      "logo": "https://nigerianbanks.xyz/logo/kuda-bank.png"
    },
    {
      "name": "Polaris Bank Limited",
      "slug": "polaris-bank",
      "code": "076",
      "logo": "https://nigerianbanks.xyz/logo/polaris-bank.png"
    },
  ];

  /// Get bank logo URL by bank name
  static String? getBankLogo(String bankName) {
    if (bankName.isEmpty) return null;
    
    final normalizedName = bankName.toLowerCase().trim();
    
    // Try exact match first
    for (var bank in banks) {
      if (bank['name'].toString().toLowerCase() == normalizedName) {
        return bank['logo'];
      }
    }
    
    // Try partial match
    for (var bank in banks) {
      if (normalizedName.contains(bank['name'].toString().toLowerCase()) ||
          bank['name'].toString().toLowerCase().contains(normalizedName)) {
        return bank['logo'];
      }
    }
    
    return null;
  }

  /// Get bank logo URL by bank code
  static String? getBankLogoByCode(String bankCode) {
    if (bankCode.isEmpty) return null;
    
    for (var bank in banks) {
      if (bank['code'] == bankCode) {
        return bank['logo'];
      }
    }
    
    return null;
  }

  /// Get bank slug by bank name
  static String? getBankSlug(String bankName) {
    if (bankName.isEmpty) return null;
    
    final normalizedName = bankName.toLowerCase().trim();
    
    for (var bank in banks) {
      if (bank['name'].toString().toLowerCase() == normalizedName ||
          normalizedName.contains(bank['name'].toString().toLowerCase())) {
        return bank['slug'];
      }
    }
    
    return null;
  }

  /// Get bank initials as fallback
  static String getBankInitials(String name) {
    if (name.isEmpty) return 'BC';
    
    final cleanName = name.trim().replaceAll(RegExp(r'\s+'), '');
    if (cleanName.length >= 2) {
      return cleanName.substring(0, 2).toUpperCase();
    } else if (cleanName.length == 1) {
      return '${cleanName[0]}C'.toUpperCase();
    }
    return 'BC';
  }
}