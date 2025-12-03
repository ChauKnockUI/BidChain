const express = require("express");
const axios = require("axios");
const router = express.Router();

// Cache for location data to reduce API calls
let countriesCache = null;
let citiesCache = {};
let districtsCache = {};
let wardsCache = {};

// Vietnam data - local database for Vietnam-specific data
const vietnamData = {
    cities: {
        'An Giang': ['Chau Doc', 'Long Xuyen', 'Tan Chau', 'An Phu', 'Chau Thanh', 'Cho Moi', 'Tan Chau Town'],
        'Ho Chi Minh City': ['District 1', 'District 2', 'District 3', 'District 4', 'District 5', 'District 6', 'District 7', 'District 8', 'District 9', 'District 10', 'District 11', 'District 12', 'Binh Tan', 'Binh Thanh', 'Can Tho', 'Go Vap', 'Phu Nhuan', 'Tan Binh', 'Tan Phu', 'Thu Duc'],
        'Ha Noi': ['Ba Dinh', 'Hoan Kiem', 'Tay Ho', 'Cau Giay', 'Dong Da', 'Hai Ba Trung', 'Hoang Mai', 'Long Bien', 'Nam Tu Liem', 'Thanh Xuan', 'Bac Tu Liem', 'Soc Son', 'Dong Anh', 'Gia Lam', 'Thanh Tri', 'Hoai Duc', 'Thach That', 'Quoc Oai', 'Phu Xuyen', 'Ung Hoa', 'My Duc', 'Dan Phuong', 'Ba Vi'],
        'Da Nang': ['Hai Chau', 'Thanh Khe', 'Son Tra', 'Ngu Hanh Son', 'Lien Chieu', 'Hoa Vang'],
        'Thua Thien-Hue': ['Hue City', 'Phu Vang', 'Phu Loc', 'An Phu', 'Phu Dien', 'Quang Dien'],
        'Hai Phong': ['Hong Bang', 'Ngo Quyen', 'Le Chan', 'Kien An', 'Do Son', 'Cat Hai'],
        'Can Tho': ['Ninh Kieu', 'Cai Rang', 'Binh Thuy', 'Phong Dien', 'Thot Not'],
    },
    districts: {
        'Ba Dinh': ['Phuong Ba Dinh', 'Phuong Ly Thuong Kiet', 'Phuong Tran Hung Dao', 'Phuong Phuc Xa'],
        'Hoan Kiem': ['Phuong Hoan Kiem', 'Phuong Trang Tien', 'Phuong Hoang Bao'],
        'District 1': ['Phuong Ben Nghe', 'Phuong Binh Thanh', 'Phuong Da Kao'],
        'District 2': ['Phuong An Phu', 'Phuong Binh An', 'Phuong Thao Dien'],
        'Hai Chau': ['Phuong Hai Chau 1', 'Phuong Hai Chau 2', 'Phuong Thanh Binh'],
    },
};

// GET all countries from REST Countries API with caching
router.get('/countries', async (req, res) => {
    try {
        console.log('[Location API] Fetching countries...');

        // Return cached data if available
        if (countriesCache) {
            console.log('[Location API] Returning cached countries:', countriesCache.length, 'items');
            return res.json({
                success: true,
                data: countriesCache,
            });
        }

        console.log('[Location API] No cache, fetching from REST Countries API...');

        // Fetch from REST Countries API with retry
        let response;
        let attempts = 0;
        const maxAttempts = 3;

        while (attempts < maxAttempts) {
            try {
                console.log(`[Location API] Attempt ${attempts + 1}/${maxAttempts}...`);
                response = await axios.get('https://restcountries.com/v3.1/all', {
                    timeout: 5000,
                    headers: {
                        'Accept': 'application/json'
                    }
                });
                console.log('[Location API] Successfully fetched from REST Countries API');
                break;
            } catch (error) {
                attempts++;
                console.error(`[Location API] Attempt ${attempts} failed:`, error.message);
                if (attempts >= maxAttempts) throw error;
                // Wait before retrying
                await new Promise(resolve => setTimeout(resolve, 1000));
            }
        }

        // Extract country names and format
        const countries = response.data
            .map(country => country.name.common)
            .sort();

        console.log('[Location API] Extracted', countries.length, 'countries');

        // Cache the result
        countriesCache = countries;

        return res.json({
            success: true,
            data: countries,
        });
    } catch (error) {
        console.error('[Location API] Error fetching countries:', error.message);
        // Return fallback data if API fails
        const fallbackCountries = ['Vietnam', 'Thailand', 'Cambodia', 'Laos', 'Indonesia', 'Philippines', 'Malaysia', 'Singapore', 'Myanmar', 'United States', 'Canada', 'United Kingdom', 'Australia', 'Japan', 'China', 'India', 'South Korea', 'France', 'Germany', 'Italy'];

        console.log('[Location API] Using fallback countries:', fallbackCountries.length, 'items');

        // Cache fallback data
        countriesCache = fallbackCountries;

        return res.json({
            success: true,
            data: fallbackCountries,
        });
    }
});

// GET cities/provinces by country
router.get('/cities/:country', (req, res) => {
    try {
        const { country } = req.params;

        // Check if we have Vietnam data
        if (country === 'Vietnam' && vietnamData.cities[country]) {
            return res.json({
                success: true,
                data: Object.keys(vietnamData.cities).sort(),
            });
        }

        // For Vietnam, return all provinces
        if (country === 'Vietnam') {
            const vietnamProvinces = [
                'An Giang', 'Ba Ria-Vung Tau', 'Bac Giang', 'Bac Kan', 'Bac Lieu', 'Bac Ninh', 'Ben Tre',
                'Binh Dinh', 'Binh Duong', 'Binh Phuoc', 'Binh Thuan', 'Ca Mau', 'Cao Bang', 'Da Nang',
                'Dak Lak', 'Dak Nong', 'Dien Bien', 'Dong Nai', 'Dong Thap', 'Gia Lai', 'Ha Giang',
                'Ha Nam', 'Ha Noi', 'Ha Tinh', 'Hai Duong', 'Hai Phong', 'Ho Chi Minh City', 'Hoa Binh',
                'Hung Yen', 'Khanh Hoa', 'Kien Giang', 'Kon Tum', 'Lai Chau', 'Lam Dong', 'Lang Son',
                'Lao Cai', 'Long An', 'Nam Dinh', 'Nghe An', 'Ninh Binh', 'Ninh Thuan', 'Phu Tho',
                'Phu Yen', 'Quang Binh', 'Quang Nam', 'Quang Ngai', 'Quang Ninh', 'Quang Tri', 'Soc Trang',
                'Son La', 'Tay Ninh', 'Thai Binh', 'Thai Nguyen', 'Thanh Hoa', 'Thua Thien-Hue',
                'Tien Giang', 'Tra Vinh', 'Tuyen Quang', 'Vinh Long', 'Vinh Phuc', 'Yen Bai',
            ];
            return res.json({
                success: true,
                data: vietnamProvinces,
            });
        }

        // For other countries, return common cities (limited data)
        const citiesMap = {
            'Thailand': ['Bangkok', 'Chiang Mai', 'Phuket', 'Krabi', 'Pattaya'],
            'Cambodia': ['Phnom Penh', 'Siem Reap', 'Kampong Cham'],
            'Laos': ['Vientiane', 'Luang Prabang', 'Savannakhet'],
            'United States': ['California', 'Texas', 'Florida', 'New York'],
            'Japan': ['Tokyo', 'Osaka', 'Kyoto', 'Yokohama'],
            'China': ['Beijing', 'Shanghai', 'Guangzhou', 'Shenzhen'],
            'India': ['Delhi', 'Mumbai', 'Bangalore', 'Chennai'],
            'United Kingdom': ['London', 'Manchester', 'Birmingham', 'Leeds'],
            'Australia': ['Sydney', 'Melbourne', 'Brisbane', 'Perth'],
        };

        const cities = citiesMap[country] || [];

        res.json({
            success: true,
            data: cities,
        });
    } catch (error) {
        console.error('Error fetching cities:', error.message);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// GET districts by city (Vietnam only)
router.get('/districts/:city', (req, res) => {
    try {
        const { city } = req.params;

        // Check cache first
        if (districtsCache[city]) {
            return res.json({
                success: true,
                data: districtsCache[city],
            });
        }

        // Get districts from Vietnam data
        const districts = vietnamData.cities[city] || [];

        // Cache the result
        if (districts.length > 0) {
            districtsCache[city] = districts;
        }

        res.json({
            success: true,
            data: districts,
        });
    } catch (error) {
        console.error('Error fetching districts:', error.message);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

// GET wards by district (Vietnam only)
router.get('/wards/:district', (req, res) => {
    try {
        const { district } = req.params;

        // Check cache first
        if (wardsCache[district]) {
            return res.json({
                success: true,
                data: wardsCache[district],
            });
        }

        // Get wards from Vietnam data
        const wards = vietnamData.districts[district] || [];

        // Cache the result
        if (wards.length > 0) {
            wardsCache[district] = wards;
        }

        res.json({
            success: true,
            data: wards,
        });
    } catch (error) {
        console.error('Error fetching wards:', error.message);
        res.status(500).json({
            success: false,
            error: error.message,
        });
    }
});

module.exports = router;
