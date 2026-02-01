const express = require('express');
const { body, validationResult } = require('express-validator');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Mock jurisdiction database
const jurisdictionDatabase = {
  'CA-LA': {
    code: 'CA-LA',
    name: 'Los Angeles County, California',
    state: 'California',
    county: 'Los Angeles',
    city: 'Los Angeles',
    coordinates: {
      latitude: 34.0522,
      longitude: -118.2437
    },
    boundaries: {
      north: 34.8233,
      south: 33.7037,
      east: -117.6462,
      west: -118.9448
    },
    lawEnforcement: {
      primary: 'Los Angeles Police Department',
      sheriff: 'Los Angeles County Sheriff\'s Department',
      emergencyNumber: '911',
      nonEmergencyNumber: '877-275-5273'
    },
    laws: {
      recording: {
        allowed: true,
        restrictions: 'Legal in public spaces, one-party consent required',
        statute: 'California Penal Code Section 632'
      },
      stopAndFrisk: {
        allowed: true,
        requirements: 'Reasonable suspicion required',
        statute: 'Terry v. Ohio, 392 U.S. 1 (1968)'
      },
      vehicleSearch: {
        warrantRequired: true,
        exceptions: ['probable cause', 'consent', 'search incident to arrest'],
        statute: 'California Vehicle Code Section 2806'
      }
    }
  },
  'NY-NYC': {
    code: 'NY-NYC',
    name: 'New York City, New York',
    state: 'New York',
    county: 'Multiple',
    city: 'New York City',
    coordinates: {
      latitude: 40.7128,
      longitude: -74.0060
    },
    boundaries: {
      north: 40.9176,
      south: 40.4774,
      east: -73.7004,
      west: -74.2591
    },
    lawEnforcement: {
      primary: 'New York Police Department',
      emergencyNumber: '911',
      nonEmergencyNumber: '646-610-5000'
    },
    laws: {
      recording: {
        allowed: true,
        restrictions: 'One-party consent required',
        statute: 'New York Penal Law Section 250.00'
      },
      stopAndFrisk: {
        allowed: true,
        requirements: 'Reasonable suspicion required, subject to NYPD reforms',
        statute: 'Terry v. Ohio, Floyd v. City of New York'
      },
      vehicleSearch: {
        warrantRequired: true,
        exceptions: ['probable cause', 'consent', 'exigent circumstances'],
        statute: 'New York Criminal Procedure Law'
      }
    }
  }
};

// Resolve jurisdiction from coordinates
router.post('/jurisdiction', authenticateToken, [
  body('latitude').isFloat({ min: -90, max: 90 }),
  body('longitude').isFloat({ min: -180, max: 180 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { latitude, longitude } = req.body;

    // Simple jurisdiction detection based on coordinates
    // In production, this would use a proper geocoding service
    let jurisdiction = null;

    for (const [code, data] of Object.entries(jurisdictionDatabase)) {
      const bounds = data.boundaries;
      if (latitude >= bounds.south && latitude <= bounds.north &&
          longitude >= bounds.west && longitude <= bounds.east) {
        jurisdiction = data;
        break;
      }
    }

    if (!jurisdiction) {
      // Default fallback jurisdiction
      jurisdiction = {
        code: 'US-DEFAULT',
        name: 'United States (General)',
        state: 'Unknown',
        coordinates: { latitude, longitude },
        lawEnforcement: {
          emergencyNumber: '911'
        },
        laws: {
          recording: {
            allowed: true,
            restrictions: 'Varies by state, generally legal in public',
            statute: 'First Amendment, state laws vary'
          },
          stopAndFrisk: {
            allowed: true,
            requirements: 'Reasonable suspicion required',
            statute: 'Terry v. Ohio, 392 U.S. 1 (1968)'
          },
          vehicleSearch: {
            warrantRequired: true,
            exceptions: ['probable cause', 'consent', 'exigent circumstances'],
            statute: 'Fourth Amendment'
          }
        }
      };
    }

    res.json({
      success: true,
      jurisdiction,
      coordinates: { latitude, longitude },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Jurisdiction resolution error:', error);
    res.status(500).json({ 
      error: 'Failed to resolve jurisdiction',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get jurisdiction by code
router.get('/jurisdiction/:code', authenticateToken, (req, res) => {
  try {
    const { code } = req.params;
    const jurisdiction = jurisdictionDatabase[code.toUpperCase()];

    if (!jurisdiction) {
      return res.status(404).json({ 
        error: 'Jurisdiction not found',
        availableJurisdictions: Object.keys(jurisdictionDatabase)
      });
    }

    res.json({
      success: true,
      jurisdiction,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Get jurisdiction error:', error);
    res.status(500).json({ 
      error: 'Failed to get jurisdiction',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Reverse geocoding (coordinates to address)
router.post('/reverse-geocode', authenticateToken, [
  body('latitude').isFloat({ min: -90, max: 90 }),
  body('longitude').isFloat({ min: -180, max: 180 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { latitude, longitude } = req.body;

    // Mock reverse geocoding
    // In production, you would use a service like Google Maps, MapBox, or OpenStreetMap
    let address = {
      street: '123 Main St',
      city: 'Unknown City',
      state: 'Unknown State',
      zipCode: '00000',
      country: 'United States'
    };

    // Simple mock based on known jurisdictions
    for (const [code, data] of Object.entries(jurisdictionDatabase)) {
      const bounds = data.boundaries;
      if (latitude >= bounds.south && latitude <= bounds.north &&
          longitude >= bounds.west && longitude <= bounds.east) {
        address = {
          street: '123 Example St',
          city: data.city,
          state: data.state,
          zipCode: data.city === 'Los Angeles' ? '90210' : '10001',
          country: 'United States'
        };
        break;
      }
    }

    res.json({
      success: true,
      address,
      coordinates: { latitude, longitude },
      accuracy: 'approximate',
      source: 'mock_geocoder',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Reverse geocoding error:', error);
    res.status(500).json({ 
      error: 'Failed to reverse geocode',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get nearby law enforcement agencies
router.post('/nearby-agencies', authenticateToken, [
  body('latitude').isFloat({ min: -90, max: 90 }),
  body('longitude').isFloat({ min: -180, max: 180 }),
  body('radius').optional().isFloat({ min: 1, max: 100 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { latitude, longitude, radius = 25 } = req.body;

    // Mock nearby agencies
    const agencies = [
      {
        name: 'Local Police Department',
        type: 'police',
        distance: 2.3,
        phone: '555-0123',
        emergencyPhone: '911',
        address: '456 Police Plaza',
        jurisdiction: 'City'
      },
      {
        name: 'County Sheriff\'s Office',
        type: 'sheriff',
        distance: 5.7,
        phone: '555-0456',
        emergencyPhone: '911',
        address: '789 County Rd',
        jurisdiction: 'County'
      },
      {
        name: 'State Highway Patrol',
        type: 'state',
        distance: 12.1,
        phone: '555-0789',
        emergencyPhone: '911',
        address: '321 State Highway',
        jurisdiction: 'State'
      }
    ];

    // Filter by radius
    const nearbyAgencies = agencies.filter(agency => agency.distance <= radius);

    res.json({
      success: true,
      agencies: nearbyAgencies,
      searchCriteria: {
        coordinates: { latitude, longitude },
        radius
      },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Nearby agencies error:', error);
    res.status(500).json({ 
      error: 'Failed to get nearby agencies',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Emergency contacts for jurisdiction
router.get('/emergency-contacts/:jurisdictionCode', authenticateToken, (req, res) => {
  try {
    const { jurisdictionCode } = req.params;
    const jurisdiction = jurisdictionDatabase[jurisdictionCode.toUpperCase()];

    const emergencyContacts = [
      {
        name: 'Emergency Services',
        phone: '911',
        type: 'emergency',
        available: '24/7',
        description: 'Police, Fire, Medical Emergency'
      },
      {
        name: 'ACLU Know Your Rights Hotline',
        phone: '877-328-2258',
        type: 'legal',
        available: '24/7',
        description: 'Legal rights information and assistance'
      },
      {
        name: 'Legal Aid Society',
        phone: '211',
        type: 'legal',
        available: 'Business hours',
        description: 'Free legal assistance for low-income individuals'
      }
    ];

    if (jurisdiction) {
      if (jurisdiction.lawEnforcement.nonEmergencyNumber) {
        emergencyContacts.push({
          name: `${jurisdiction.lawEnforcement.primary} Non-Emergency`,
          phone: jurisdiction.lawEnforcement.nonEmergencyNumber,
          type: 'police',
          available: '24/7',
          description: 'Non-emergency police matters'
        });
      }
    }

    res.json({
      success: true,
      jurisdiction: jurisdiction ? {
        code: jurisdiction.code,
        name: jurisdiction.name
      } : null,
      emergencyContacts,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Emergency contacts error:', error);
    res.status(500).json({ 
      error: 'Failed to get emergency contacts',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;