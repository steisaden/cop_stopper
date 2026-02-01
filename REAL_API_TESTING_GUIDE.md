# Real Police API Testing Guide

This guide shows you how to test actual police databases and APIs instead of using mock data.

## 🎯 Available Real APIs

### 1. UK Police API (data.police.uk)
- **Status**: ✅ Active and free
- **Authentication**: None required
- **Data**: Police forces, senior officers, crime data, stop & search
- **Coverage**: United Kingdom
- **Rate Limits**: Reasonable for testing

### 2. Washington Post Police Shootings Database
- **Status**: ✅ Active and free
- **Authentication**: None required
- **Data**: Fatal police shootings since 2015
- **Coverage**: United States
- **Format**: CSV data from GitHub

### 3. Chicago Data Portal
- **Status**: ✅ Active and free
- **Authentication**: None required
- **Data**: Various city datasets including police-related data
- **Coverage**: Chicago, IL
- **API**: Socrata-based

### 4. OpenOversight
- **Status**: ⚠️ Website active, API availability varies
- **Authentication**: Varies by deployment
- **Data**: Police officer profiles and photos
- **Coverage**: Multiple US cities

### 5. Fatal Encounters
- **Status**: ⚠️ Website active, data access varies
- **Authentication**: None for website
- **Data**: Police-involved deaths
- **Coverage**: United States

## 🚀 Quick Start Testing

### Option 1: Command Line Test (Fastest)

1. **Run the standalone test script:**
```bash
dart test_police_apis.dart
```

This will test all available APIs and show you real-time results.

### Option 2: Backend API Testing

1. **Start the backend server:**
```bash
cd backend
npm install
npm run dev
```

2. **Test the APIs via HTTP:**
```bash
# Get auth token first
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Test all APIs
curl -X GET http://localhost:3000/api/test/test-apis \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get real UK police officers
curl -X GET http://localhost:3000/api/test/uk-officers \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get specific force officers (Metropolitan Police)
curl -X GET http://localhost:3000/api/test/uk-officers/metropolitan \
  -H "Authorization: Bearer YOUR_TOKEN"

# Get Washington Post police shootings data
curl -X GET http://localhost:3000/api/test/police-shootings?limit=50 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Option 3: Mobile App Testing

1. **Add the API test screen to your app navigation**
2. **Run the Flutter app:**
```bash
cd mobile
flutter run
```
3. **Navigate to the API Test Screen**
4. **Run the tests and search for real officers**

## 📊 Expected Results

### UK Police API
```json
{
  "uk_police": {
    "status": "success",
    "forces_count": 45,
    "sample_forces": [
      {"id": "metropolitan", "name": "Metropolitan Police Service"},
      {"id": "city-of-london", "name": "City of London Police"},
      {"id": "west-midlands", "name": "West Midlands Police"}
    ],
    "officers_count": 12,
    "sample_officers": [
      {"name": "Sir Mark Rowley", "rank": "Commissioner"},
      {"name": "Dame Lynne Owens", "rank": "Assistant Commissioner"}
    ]
  }
}
```

### Washington Post Data
```json
{
  "washington_post": {
    "status": "success",
    "total_records": 8500,
    "header": "id,name,date,manner_of_death,armed,age,gender,race,city,state,signs_of_mental_illness,threat_level,flee,body_camera",
    "sample_record": "1,Tim Elliot,2015-01-02,shot,gun,53,M,A,Shelton,WA,True,attack,Not fleeing,False"
  }
}
```

## 🔧 Integration Examples

### Using Real UK Police Data in Your App

```dart
// Search for real UK police officers
final apiService = RealPoliceApiService();
final officers = await apiService.searchUKPoliceOfficers(
  forceId: 'metropolitan', // Optional: specific force
  nameQuery: 'commissioner', // Optional: name filter
);

// Display real officer data
for (final officer in officers) {
  print('${officer.name} - ${officer.rank} at ${officer.department}');
}
```

### Backend Integration

```javascript
// Get real police data in your backend
const axios = require('axios');

async function getRealPoliceData() {
  // Get UK police forces
  const forcesResponse = await axios.get('https://data.police.uk/api/forces');
  
  // Get Washington Post shootings data
  const shootingsResponse = await axios.get(
    'https://raw.githubusercontent.com/washingtonpost/data-police-shootings/master/fatal-police-shootings-data.csv'
  );
  
  return {
    forces: forcesResponse.data,
    shootings: parseCSV(shootingsResponse.data)
  };
}
```

## 🛡️ API Limitations & Considerations

### UK Police API
- **Rate Limits**: No official limits, but be respectful
- **Data Scope**: Only senior officers are publicly available
- **Coverage**: UK only
- **Complaints**: Not available in public API

### Washington Post Data
- **Update Frequency**: Regularly updated
- **Data Quality**: High, journalistic standards
- **Scope**: Fatal shootings only
- **Format**: CSV, requires parsing

### Chicago Data Portal
- **Rate Limits**: Standard Socrata limits
- **Authentication**: Optional for higher limits
- **Data Variety**: Multiple police-related datasets
- **Quality**: Official city data

## 🔍 Testing Checklist

- [ ] **UK Police API**: Can fetch forces and officers
- [ ] **Washington Post**: Can download and parse CSV data
- [ ] **Chicago Portal**: Can access metadata and datasets
- [ ] **OpenOversight**: Website accessible, check for API
- [ ] **Fatal Encounters**: Website accessible, check for data links
- [ ] **Error Handling**: APIs gracefully handle failures
- [ ] **Rate Limiting**: Respectful request timing
- [ ] **Data Parsing**: Correctly parse different data formats

## 🚨 Troubleshooting

### Common Issues

1. **Network Timeouts**
   - Increase timeout values
   - Check internet connection
   - Some APIs may be slow

2. **CORS Errors (Browser)**
   - Use backend proxy for API calls
   - Some APIs don't support browser requests

3. **Rate Limiting**
   - Add delays between requests
   - Implement exponential backoff
   - Cache responses when possible

4. **Data Format Changes**
   - APIs may change their response format
   - Implement robust error handling
   - Log unexpected responses

### Debug Commands

```bash
# Test individual APIs
curl -v https://data.police.uk/api/forces
curl -v https://data.cityofchicago.org/api/views/metadata/v1
curl -v https://openoversight.com/

# Check response headers
curl -I https://data.police.uk/api/forces

# Test with different user agents
curl -H "User-Agent: CopStopper/1.0" https://data.police.uk/api/forces
```

## 📈 Next Steps

1. **Implement Caching**: Cache API responses to reduce load
2. **Add More APIs**: Integrate additional police databases
3. **Data Enrichment**: Combine data from multiple sources
4. **Real-Time Updates**: Set up webhooks or polling for updates
5. **Analytics**: Track API usage and performance

## 🔗 API Documentation Links

- [UK Police API Docs](https://data.police.uk/docs/)
- [Chicago Data Portal](https://data.cityofchicago.org/)
- [Washington Post GitHub](https://github.com/washingtonpost/data-police-shootings)
- [OpenOversight](https://openoversight.com/)
- [Fatal Encounters](https://fatalencounters.org/)

## ⚖️ Legal & Ethical Considerations

- **Public Data**: All APIs use publicly available data
- **Attribution**: Credit data sources appropriately
- **Rate Limits**: Respect API terms of service
- **Privacy**: Handle personal information responsibly
- **Accuracy**: Verify data accuracy when possible
- **Updates**: Keep data current and note last update times

---

**Ready to test real police APIs?** Start with the command-line test script for the quickest results!