const express = require('express');
const axios = require('axios');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Test real police APIs from backend
router.get('/test-apis', authenticateToken, async (req, res) => {
  try {
    const results = {};
    
    console.log('🔍 Testing Real Police APIs from backend...');
    
    // Test UK Police API
    try {
      console.log('Testing UK Police API...');
      const ukResponse = await axios.get('https://data.police.uk/api/forces', {
        timeout: 10000,
        headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
      });
      
      if (ukResponse.status === 200) {
        results.uk_police = {
          status: 'success',
          forces_count: ukResponse.data.length,
          sample_forces: ukResponse.data.slice(0, 3).map(f => ({ id: f.id, name: f.name }))
        };
        console.log(`✅ UK Police API: ${ukResponse.data.length} forces found`);
        
        // Test getting officers for Leicestershire Police (known to have data)
        try {
          const officersResponse = await axios.get(
            'https://data.police.uk/api/forces/leicestershire/people',
            {
              timeout: 10000,
              headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
            }
          );
          
          if (officersResponse.status === 200) {
            results.uk_police.officers_count = officersResponse.data.length;
            results.uk_police.sample_officers = officersResponse.data.slice(0, 2).map(o => ({
              name: o.name,
              rank: o.rank
            }));
            console.log(`✅ UK Police Officers: ${officersResponse.data.length} senior officers found for Leicestershire`);
          }
        } catch (e) {
          console.log('⚠️ UK Police officers request failed:', e.message);
        }
      }
    } catch (e) {
      results.uk_police = { status: 'error', message: e.message };
      console.log('❌ UK Police API failed:', e.message);
    }
    
    // Test OpenOversight
    try {
      console.log('Testing OpenOversight...');
      const openOversightResponse = await axios.get('https://openoversight.com/', {
        timeout: 10000,
        headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
      });
      
      if (openOversightResponse.status === 200) {
        results.openoversight = {
          status: 'success',
          message: 'Website accessible',
          has_api_mention: openOversightResponse.data.toLowerCase().includes('api')
        };
        console.log('✅ OpenOversight website accessible');
      }
    } catch (e) {
      results.openoversight = { status: 'error', message: e.message };
      console.log('❌ OpenOversight failed:', e.message);
    }
    
    // Test Chicago Data Portal
    try {
      console.log('Testing Chicago Data Portal...');
      const chicagoResponse = await axios.get('https://data.cityofchicago.org/api/views/metadata/v1', {
        timeout: 10000,
        headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
      });
      
      if (chicagoResponse.status === 200) {
        results.chicago_data = {
          status: 'success',
          message: 'API accessible'
        };
        console.log('✅ Chicago Data Portal API accessible');
        
        // Try to get police datasets
        try {
          const datasetsResponse = await axios.get(
            'https://data.cityofchicago.org/api/views.json?limitTo=datasets&q=police',
            {
              timeout: 10000,
              headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
            }
          );
          
          if (datasetsResponse.status === 200) {
            results.chicago_data.datasets_count = datasetsResponse.data.length;
            results.chicago_data.sample_datasets = datasetsResponse.data.slice(0, 3).map(d => d.name);
            console.log(`✅ Chicago Police Datasets: ${datasetsResponse.data.length} found`);
          }
        } catch (e) {
          console.log('⚠️ Chicago datasets request failed:', e.message);
        }
      }
    } catch (e) {
      results.chicago_data = { status: 'error', message: e.message };
      console.log('❌ Chicago Data Portal failed:', e.message);
    }
    
    // Test Washington Post Police Shootings Data
    try {
      console.log('Testing Washington Post data...');
      const wpResponse = await axios.get(
        'https://raw.githubusercontent.com/washingtonpost/data-police-shootings/master/fatal-police-shootings-data.csv',
        {
          timeout: 15000,
          headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
        }
      );
      
      if (wpResponse.status === 200) {
        const lines = wpResponse.data.split('\n');
        results.washington_post = {
          status: 'success',
          total_records: lines.length - 1, // -1 for header
          header: lines[0],
          sample_record: lines.length > 1 ? lines[1] : null
        };
        console.log(`✅ Washington Post data: ${lines.length - 1} records found`);
      }
    } catch (e) {
      results.washington_post = { status: 'error', message: e.message };
      console.log('❌ Washington Post data failed:', e.message);
    }
    
    // Test Fatal Encounters
    try {
      console.log('Testing Fatal Encounters...');
      const feResponse = await axios.get('https://fatalencounters.org/', {
        timeout: 10000,
        headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
      });
      
      if (feResponse.status === 200) {
        results.fatal_encounters = {
          status: 'success',
          message: 'Website accessible',
          has_data_mention: feResponse.data.toLowerCase().includes('download') || 
                           feResponse.data.toLowerCase().includes('csv') ||
                           feResponse.data.toLowerCase().includes('data'),
          has_google_sheets: feResponse.data.includes('docs.google.com') || 
                           feResponse.data.includes('sheets.google.com')
        };
        console.log('✅ Fatal Encounters website accessible');
      }
    } catch (e) {
      results.fatal_encounters = { status: 'error', message: e.message };
      console.log('❌ Fatal Encounters failed:', e.message);
    }
    
    // Summary
    const successCount = Object.values(results).filter(r => r.status === 'success').length;
    const totalCount = Object.keys(results).length;
    
    console.log(`\n📊 API Test Summary: ${successCount}/${totalCount} APIs accessible`);
    
    res.json({
      success: true,
      summary: {
        total_apis: totalCount,
        successful_apis: successCount,
        success_rate: `${Math.round((successCount / totalCount) * 100)}%`
      },
      results,
      timestamp: new Date().toISOString(),
      note: 'These are real police databases and APIs. Some may have rate limits or require authentication for full access.'
    });
    
  } catch (error) {
    console.error('API test error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to test APIs',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get real UK police officers
router.get('/uk-officers/:forceId?', authenticateToken, async (req, res) => {
  try {
    const { forceId } = req.params;
    const officers = [];
    
    if (forceId) {
      // Get officers for specific force
      const response = await axios.get(
        `https://data.police.uk/api/forces/${forceId}/people`,
        {
          timeout: 10000,
          headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
        }
      );
      
      if (response.status === 200) {
        officers.push(...response.data.map(officer => ({
          id: `${forceId}_${officer.name.replace(/\s+/g, '_')}`,
          name: officer.name,
          rank: officer.rank,
          department: forceId,
          bio: officer.bio || '',
          contact_details: officer.contact_details || {},
          data_source: 'UK Police API',
          reliability: 0.9
        })));
      }
    } else {
      // Get officers from multiple forces (limited to first 3 for demo)
      const forcesResponse = await axios.get('https://data.police.uk/api/forces', {
        timeout: 10000,
        headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
      });
      
      if (forcesResponse.status === 200) {
        const forces = forcesResponse.data.slice(0, 3); // Limit to 3 forces
        
        for (const force of forces) {
          try {
            const officersResponse = await axios.get(
              `https://data.police.uk/api/forces/${force.id}/people`,
              {
                timeout: 10000,
                headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
              }
            );
            
            if (officersResponse.status === 200) {
              officers.push(...officersResponse.data.map(officer => ({
                id: `${force.id}_${officer.name.replace(/\s+/g, '_')}`,
                name: officer.name,
                rank: officer.rank,
                department: force.name,
                bio: officer.bio || '',
                contact_details: officer.contact_details || {},
                data_source: 'UK Police API',
                reliability: 0.9
              })));
            }
            
            // Be respectful to the API
            await new Promise(resolve => setTimeout(resolve, 500));
          } catch (e) {
            console.log(`Failed to get officers for ${force.id}:`, e.message);
          }
        }
      }
    }
    
    res.json({
      success: true,
      officers,
      total: officers.length,
      force_id: forceId || 'multiple',
      note: 'UK Police API only provides senior officer information. This is real data from the UK government.',
      timestamp: new Date().toISOString()
    });
    
  } catch (error) {
    console.error('UK officers error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get UK officers',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get Washington Post police shootings data (sample)
router.get('/police-shootings', authenticateToken, async (req, res) => {
  try {
    const { limit = 100 } = req.query;
    
    const response = await axios.get(
      'https://raw.githubusercontent.com/washingtonpost/data-police-shootings/master/fatal-police-shootings-data.csv',
      {
        timeout: 15000,
        headers: { 'User-Agent': 'CopStopper-Backend/1.0' }
      }
    );
    
    if (response.status === 200) {
      const lines = response.data.split('\n');
      const header = lines[0].split(',');
      const records = [];
      
      // Parse CSV data (limited sample)
      for (let i = 1; i < Math.min(lines.length, parseInt(limit) + 1); i++) {
        if (lines[i].trim()) {
          const values = lines[i].split(',');
          const record = {};
          header.forEach((col, index) => {
            record[col.trim()] = values[index]?.trim() || '';
          });
          records.push(record);
        }
      }
      
      res.json({
        success: true,
        records,
        total_available: lines.length - 1,
        returned: records.length,
        header,
        data_source: 'Washington Post Police Shootings Database',
        note: 'This is real data from The Washington Post\'s database of police shootings.',
        timestamp: new Date().toISOString()
      });
    } else {
      throw new Error(`HTTP ${response.status}`);
    }
    
  } catch (error) {
    console.error('Police shootings data error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to get police shootings data',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;