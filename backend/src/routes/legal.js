const express = require('express');
const { body, validationResult } = require('express-validator');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Mock legal database
const legalDatabase = {
  jurisdictions: {
    'CA': {
      name: 'California',
      rights: [
        'You have the right to remain silent',
        'You have the right to refuse searches without a warrant',
        'You have the right to record police interactions in public',
        'You have the right to ask if you are free to leave'
      ],
      laws: {
        recording: 'Legal in public spaces (Penal Code 632)',
        search: 'Requires warrant or probable cause (4th Amendment)',
        detention: 'Must have reasonable suspicion (Terry v. Ohio)'
      }
    },
    'NY': {
      name: 'New York',
      rights: [
        'You have the right to remain silent',
        'You have the right to refuse searches without a warrant',
        'You have the right to record police interactions',
        'You have the right to ask for badge numbers'
      ],
      laws: {
        recording: 'Legal with one-party consent (Penal Law 250.00)',
        search: 'Requires warrant except in exigent circumstances',
        detention: 'Must have reasonable suspicion'
      }
    }
  },
  scenarios: {
    traffic_stop: {
      advice: [
        'Keep your hands visible on the steering wheel',
        'Provide license, registration, and insurance when requested',
        'You may remain silent beyond providing identification',
        'You can refuse searches of your vehicle without a warrant'
      ],
      warnings: [
        'Do not reach for documents until asked',
        'Avoid sudden movements',
        'Do not argue or resist, even if you believe the stop is unlawful'
      ]
    },
    pedestrian_stop: {
      advice: [
        'Ask "Am I free to leave?"',
        'You are not required to answer questions beyond identification',
        'You can refuse searches without a warrant',
        'Stay calm and keep your hands visible'
      ],
      warnings: [
        'Do not run or resist',
        'Avoid reaching into pockets without permission',
        'Do not argue about the legality of the stop'
      ]
    }
  }
};

// Get legal guidance based on location and situation
router.post('/guidance', authenticateToken, [
  body('latitude').isFloat({ min: -90, max: 90 }),
  body('longitude').isFloat({ min: -180, max: 180 }),
  body('scenario').isIn(['traffic_stop', 'pedestrian_stop', 'home_visit', 'general'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { latitude, longitude, scenario, context } = req.body;

    // Mock jurisdiction detection based on coordinates
    // In production, this would use a proper geocoding service
    let jurisdiction = 'CA'; // Default
    if (latitude > 40 && latitude < 45 && longitude > -80 && longitude < -70) {
      jurisdiction = 'NY';
    }

    const jurisdictionData = legalDatabase.jurisdictions[jurisdiction];
    const scenarioData = legalDatabase.scenarios[scenario] || legalDatabase.scenarios.general;

    const guidance = {
      jurisdiction: {
        code: jurisdiction,
        name: jurisdictionData.name,
        rights: jurisdictionData.rights,
        laws: jurisdictionData.laws
      },
      scenario: {
        type: scenario,
        advice: scenarioData?.advice || [
          'You have the right to remain silent',
          'You have the right to refuse searches without a warrant',
          'You have the right to record the interaction',
          'Stay calm and comply with lawful orders'
        ],
        warnings: scenarioData?.warnings || [
          'Do not resist or argue',
          'Keep your hands visible',
          'Follow lawful orders'
        ]
      },
      emergency_contacts: [
        {
          name: 'ACLU Know Your Rights Hotline',
          phone: '877-328-2258',
          available: '24/7'
        },
        {
          name: 'Local Legal Aid',
          phone: '211',
          available: 'Business hours'
        }
      ],
      timestamp: new Date().toISOString(),
      location: { latitude, longitude }
    };

    res.json({
      success: true,
      guidance
    });

  } catch (error) {
    console.error('Legal guidance error:', error);
    res.status(500).json({ 
      error: 'Failed to get legal guidance',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Analyze transcription for legal concerns
router.post('/analyze', authenticateToken, [
  body('text').isLength({ min: 1 }),
  body('jurisdiction').optional().isLength({ min: 2, max: 2 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { text, jurisdiction = 'CA' } = req.body;

    // Simple keyword analysis (in production, use NLP/AI)
    const concernKeywords = {
      search: ['search', 'look through', 'check your'],
      detention: ['detain', 'arrest', 'custody', 'handcuffs'],
      rights: ['right to remain silent', 'miranda', 'lawyer'],
      force: ['force', 'resist', 'comply', 'weapon']
    };

    const alerts = [];
    const recommendations = [];

    // Analyze text for concerns
    const lowerText = text.toLowerCase();
    
    if (concernKeywords.search.some(keyword => lowerText.includes(keyword))) {
      alerts.push({
        type: 'search_request',
        severity: 'medium',
        message: 'Officer may be requesting to search. You have the right to refuse without a warrant.',
        action: 'Say: "I do not consent to any searches."'
      });
    }

    if (concernKeywords.detention.some(keyword => lowerText.includes(keyword))) {
      alerts.push({
        type: 'detention',
        severity: 'high',
        message: 'You may be under arrest or detention.',
        action: 'Ask: "Am I under arrest?" and request a lawyer immediately.'
      });
    }

    if (concernKeywords.force.some(keyword => lowerText.includes(keyword))) {
      alerts.push({
        type: 'force_concern',
        severity: 'high',
        message: 'Potential use of force situation detected.',
        action: 'Comply with lawful orders and document everything. Do not resist.'
      });
    }

    // General recommendations
    recommendations.push('Continue recording the interaction');
    recommendations.push('Remain calm and respectful');
    recommendations.push('Ask for badge numbers and names');

    const analysis = {
      text,
      jurisdiction,
      alerts,
      recommendations,
      confidence: 0.85,
      timestamp: new Date().toISOString(),
      userId: req.user.userId
    };

    res.json({
      success: true,
      analysis
    });

  } catch (error) {
    console.error('Legal analysis error:', error);
    res.status(500).json({ 
      error: 'Failed to analyze text',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get jurisdiction information
router.get('/jurisdiction/:code', authenticateToken, (req, res) => {
  const { code } = req.params;
  const jurisdiction = legalDatabase.jurisdictions[code.toUpperCase()];

  if (!jurisdiction) {
    return res.status(404).json({ error: 'Jurisdiction not found' });
  }

  res.json({
    success: true,
    jurisdiction: {
      code: code.toUpperCase(),
      ...jurisdiction
    }
  });
});

module.exports = router;