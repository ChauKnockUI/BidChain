// Vietnamese locations data - Country, City, District, Ward
class LocationData {
  // Get all countries (simplified - assuming Vietnam)
  static List<String> getCountries() {
    return ['Vietnam'];
  }

  // Get cities/provinces by country
  static List<String> getCities(String country) {
    if (country == 'Vietnam') {
      return [
        'An Giang',
        'Ba Ria-Vung Tau',
        'Bac Giang',
        'Bac Kan',
        'Bac Lieu',
        'Bac Ninh',
        'Ben Tre',
        'Binh Dinh',
        'Binh Duong',
        'Binh Phuoc',
        'Binh Thuan',
        'Ca Mau',
        'Cao Bang',
        'Da Nang',
        'Dak Lak',
        'Dak Nong',
        'Dien Bien',
        'Dong Nai',
        'Dong Thap',
        'Gia Lai',
        'Ha Giang',
        'Ha Nam',
        'Ha Noi',
        'Ha Tinh',
        'Hai Duong',
        'Hai Phong',
        'Ho Chi Minh City',
        'Hoa Binh',
        'Hung Yen',
        'Khanh Hoa',
        'Kien Giang',
        'Kon Tum',
        'Lai Chau',
        'Lam Dong',
        'Lang Son',
        'Lao Cai',
        'Long An',
        'Nam Dinh',
        'Nghe An',
        'Ninh Binh',
        'Ninh Thuan',
        'Phu Tho',
        'Phu Yen',
        'Quang Binh',
        'Quang Nam',
        'Quang Ngai',
        'Quang Ninh',
        'Quang Tri',
        'Soc Trang',
        'Son La',
        'Tay Ninh',
        'Thai Binh',
        'Thai Nguyen',
        'Thanh Hoa',
        'Thua Thien-Hue',
        'Tien Giang',
        'Tra Vinh',
        'Tuyen Quang',
        'Vinh Long',
        'Vinh Phuc',
        'Yen Bai',
      ];
    }
    return [];
  }

  // Get districts by city
  static List<String> getDistricts(String city) {
    final districts = {
      'Ha Noi': [
        'Ba Dinh',
        'Hoan Kiem',
        'Tay Ho',
        'Cau Giay',
        'Dong Da',
        'Hai Ba Trung',
        'Hoang Mai',
        'Long Bien',
        'Nam Tu Liem',
        'Thanh Xuan',
        'Bac Tu Liem',
        'Soc Son',
        'Dong Anh',
        'Gia Lam',
        'Thanh Tri',
        'Hoai Duc',
        'Thach That',
        'Quoc Oai',
        'Phu Xuyen',
        'Ung Hoa',
        'My Duc',
        'Dan Phuong',
        'Ba Vi',
        'Trang Xa',
      ],
      'Ho Chi Minh City': [
        'District 1',
        'District 2',
        'District 3',
        'District 4',
        'District 5',
        'District 6',
        'District 7',
        'District 8',
        'District 9',
        'District 10',
        'District 11',
        'District 12',
        'Binh Tan',
        'Binh Thanh',
        'Dong Nai',
        'Go Vap',
        'Nhan Chinh',
        'Phu Nhuan',
        'Tan Binh',
        'Tan Phu',
        'Thu Duc',
        'Can Tho',
      ],
      'Da Nang': [
        'Hai Chau',
        'Thanh Khe',
        'Son Tra',
        'Ngu Hanh Son',
        'Lien Chieu',
        'Hoa Vang',
        'Hoang Sa',
      ],
    };
    return districts[city] ?? [];
  }

  // Get wards by district
  static List<String> getWards(String district) {
    final wards = {
      'Ba Dinh': [
        'Phuong Ba Dinh',
        'Phuong Ly Thuong Kiet',
        'Phuong Tran Hung Dao',
      ],
      'Hoan Kiem': [
        'Phuong Hoan Kiem',
        'Phuong Trang Tien',
        'Phuong Hoang Bao',
      ],
      'District 1': ['Phuong Ben Nghe', 'Phuong Binh Thanh', 'Phuong Da Kao'],
      'District 2': ['Phuong An Phu', 'Phuong Binh An', 'Phuong Thao Dien'],
      'Hai Chau': [
        'Phuong Hai Chau 1',
        'Phuong Hai Chau 2',
        'Phuong Thanh Binh',
      ],
    };
    return wards[district] ?? [];
  }
}
