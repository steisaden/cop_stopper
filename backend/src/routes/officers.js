const express = require('express');
const { body, validationResult } = require('express-validator');
const { authenticateToken } = require('../middleware/auth');
const axios = require('axios');
const router = express.Router();

// Police conduct database API configurations
const POLICE_APIS = {
  cpdp: {
    baseUrl: 'https://api.cpdp.co/api/v2',
    name: 'Chicago Police Data Project',
    reliability: 0.9
  },
  policeDataInitiative: {
    baseUrl: 'https://api.policedatainitiative.org/v1',
    name: 'Police Data Initiative',
    reliability: 0.8
  },
  transparencyProject: {
    baseUrl: 'https://api.transparencyproject.org/v1',
    name: 'Transparency Project',
    reliability: 0.85
  },
  mappingPoliceViolence: {
    baseUrl: 'https://api.mappingpoliceviolence.org/v1',
    name: 'Mapping Police Violence',
    reliability: 0.9
  }
};

// Mock officer database (in production, this would be real public records APIs)
const officerDatabase = {
  'LAPD-12345': {
    badgeNumber: '12345',
    name: 'John Smith',
    department: 'Los Angeles Police Department',
    rank: 'Officer',
    yearsOfService: 8,
    unit: 'Patrol Division',
    complaints: [
      {
        id: 'C-2023-001',
        date: '2023-03-15',
        type: 'Excessive Force',
        status: 'Sustained',
        description: 'Use of force complaint during traffic stop',
        outcome: 'Suspension - 30 days'
      },
      {
        id: 'C-2022-045',
        date: '2022-11-22',
        type: 'Discourtesy',
        status: 'Not Sustained',
        description: 'Rude behavior complaint',
        outcome: 'No action taken'
      },
      {
        id: 'C-2021-089',
        date: '2021-08-10',
        type: 'False Arrest',
        status: 'Sustained',
        description: 'Arrested individual without probable cause',
        outcome: 'Written reprimand'
      }
    ],
    commendations: [
      {
        id: 'COM-2023-012',
        date: '2023-01-10',
        type: 'Life Saving',
        description: 'Performed CPR on accident victim'
      }
    ],
    lastUpdated: '2023-12-01'
  },
  'NYPD-67890': {
    badgeNumber: '67890',
    name: 'Maria Rodriguez',
    department: 'New York Police Department',
    rank: 'Detective',
    yearsOfService: 12,
    unit: 'Detective Bureau',
    complaints: [],
    commendations: [
      {
        id: 'COM-2023-089',
        date: '2023-06-15',
        type: 'Exceptional Merit',
        description: 'Solved complex fraud case'
      },
      {
        id: 'COM-2022-156',
        date: '2022-09-30',
        type: 'Community Service',
        description: 'Volunteer work with youth programs'
      }
    ],
    lastUpdated: '2023-11-15'
  },
  'CPD-24680': {
    badgeNumber: '24680',
    name: 'Michael Johnson',
    department: 'Chicago Police Department',
    rank: 'Sergeant',
    yearsOfService: 15,
    unit: 'Gang Unit',
    complaints: [
      {
        id: 'C-2023-156',
        date: '2023-09-20',
        type: 'Excessive Force',
        status: 'Sustained',
        description: 'Used excessive force during arrest',
        outcome: 'Suspension - 15 days'
      },
      {
        id: 'C-2023-089',
        date: '2023-05-12',
        type: 'Search and Seizure',
        status: 'Not Sustained',
        description: 'Illegal search of vehicle',
        outcome: 'Training required'
      },
      {
        id: 'C-2022-234',
        date: '2022-12-03',
        type: 'Bias-Based Policing',
        status: 'Sustained',
        description: 'Racial profiling during traffic stop',
        outcome: 'Suspension - 45 days'
      },
      {
        id: 'C-2022-178',
        date: '2022-07-15',
        type: 'Excessive Force',
        status: 'Sustained',
        description: 'Unnecessary use of taser',
        outcome: 'Written reprimand'
      },
      {
        id: 'C-2021-345',
        date: '2021-11-28',
        type: 'Discourtesy',
        status: 'Not Sustained',
        description: 'Unprofessional conduct',
        outcome: 'Counseling'
      }
    ],
    commendations: [
      {
        id: 'COM-2020-045',
        date: '2020-03-22',
        type: 'Bravery',
        description: 'Rescued civilians from burning building'
      }
    ],
    lastUpdated: '2023-12-15'
  },
  'SFPD-13579': {
    badgeNumber: '13579',
    name: 'Sarah Chen',
    department: 'San Francisco Police Department',
    rank: 'Officer',
    yearsOfService: 6,
    unit: 'Community Relations',
    complaints: [
      {
        id: 'C-2023-067',
        date: '2023-04-18',
        type: 'Failure to Take Action',
        status: 'Not Sustained',
        description: 'Failed to respond to domestic violence call',
        outcome: 'Additional training'
      }
    ],
    commendations: [
      {
        id: 'COM-2023-234',
        date: '2023-08-14',
        type: 'Community Service',
        description: 'Organized youth basketball league'
      },
      {
        id: 'COM-2022-189',
        date: '2022-12-10',
        type: 'Exceptional Merit',
        description: 'De-escalated potentially violent situation'
      },
      {
        id: 'COM-2022-067',
        date: '2022-06-05',
        type: 'Life Saving',
        description: 'Administered Narcan to overdose victim'
      }
    ],
    lastUpdated: '2023-11-28'
  },
  'BPD-97531': {
    badgeNumber: '97531',
    name: 'Robert Williams',
    department: 'Boston Police Department',
    rank: 'Lieutenant',
    yearsOfService: 20,
    unit: 'Internal Affairs',
    complaints: [
      {
        id: 'C-2019-123',
        date: '2019-02-14',
        type: 'Corruption',
        status: 'Sustained',
        description: 'Accepted bribes from local business',
        outcome: 'Demotion and suspension - 90 days'
      }
    ],
    commendations: [
      {
        id: 'COM-2023-456',
        date: '2023-07-20',
        type: 'Leadership',
        description: 'Led successful anti-corruption investigation'
      },
      {
        id: 'COM-2021-789',
        date: '2021-09-11',
        type: 'Exceptional Merit',
        description: 'Solved cold case murder from 1995'
      }
    ],
    lastUpdated: '2023-12-05'
  },
  'HPD-86420': {
    badgeNumber: '86420',
    name: 'David Martinez',
    department: 'Houston Police Department',
    rank: 'Officer',
    yearsOfService: 4,
    unit: 'Traffic Division',
    complaints: [
      {
        id: 'C-2023-234',
        date: '2023-10-05',
        type: 'Excessive Force',
        status: 'Under Investigation',
        description: 'Alleged excessive force during DUI arrest',
        outcome: 'Pending'
      },
      {
        id: 'C-2023-178',
        date: '2023-06-22',
        type: 'Discourtesy',
        status: 'Sustained',
        description: 'Used inappropriate language during traffic stop',
        outcome: 'Written reprimand'
      }
    ],
    commendations: [],
    lastUpdated: '2023-12-10'
  },
  'PPD-55555': {
    badgeNumber: '55555',
    name: 'Jennifer Taylor',
    department: 'Philadelphia Police Department',
    rank: 'Detective',
    yearsOfService: 10,
    unit: 'Homicide Division',
    complaints: [],
    commendations: [
      {
        id: 'COM-2023-678',
        date: '2023-11-03',
        type: 'Exceptional Merit',
        description: 'Solved triple homicide case'
      },
      {
        id: 'COM-2023-345',
        date: '2023-05-17',
        type: 'Community Service',
        description: 'Mentored at-risk youth program'
      },
      {
        id: 'COM-2022-890',
        date: '2022-08-29',
        type: 'Bravery',
        description: 'Apprehended armed robbery suspect'
      }
    ],
    lastUpdated: '2023-12-12'
  },
  'MPD-11111': {
    badgeNumber: '11111',
    name: 'Anthony Brown',
    department: 'Miami Police Department',
    rank: 'Captain',
    yearsOfService: 25,
    unit: 'Narcotics Division',
    complaints: [
      {
        id: 'C-2020-456',
        date: '2020-08-15',
        type: 'Excessive Force',
        status: 'Sustained',
        description: 'Used excessive force during drug raid',
        outcome: 'Suspension - 60 days'
      },
      {
        id: 'C-2018-789',
        date: '2018-12-07',
        type: 'Search and Seizure',
        status: 'Not Sustained',
        description: 'Conducted warrantless search',
        outcome: 'Training completed'
      }
    ],
    commendations: [
      {
        id: 'COM-2023-999',
        date: '2023-09-25',
        type: 'Leadership',
        description: 'Led major drug trafficking investigation'
      },
      {
        id: 'COM-2019-777',
        date: '2019-04-12',
        type: 'Exceptional Merit',
        description: 'Dismantled international drug ring'
      }
    ],
    lastUpdated: '2023-12-08'
  }
};

// Search officers by badge number or name across multiple databases
router.get('/search', authenticateToken, async (req, res) => {
  try {
    const { badge, name, department, limit = 20 } = req.query;

    if (!badge && !name) {
      return res.status(400).json({ 
        error: 'Either badge number or name is required for search' 
      });
    }

    let results = [];

    // Search local database first
    if (badge) {
      const officerKey = Object.keys(officerDatabase).find(key => 
        officerDatabase[key].badgeNumber === badge
      );
      if (officerKey) {
        results.push({
          ...officerDatabase[officerKey],
          dataSource: 'Local Database',
          reliability: 0.95
        });
      }
    }

    if (name && results.length === 0) {
      const nameResults = Object.values(officerDatabase).filter(officer =>
        officer.name.toLowerCase().includes(name.toLowerCase())
      );
      results = results.concat(nameResults.map(officer => ({
        ...officer,
        dataSource: 'Local Database',
        reliability: 0.95
      })));
    }

    // Search external APIs in parallel
    const externalSearches = await Promise.allSettled([
      searchCPDP(name || badge, department),
      searchPoliceDataInitiative(name || badge, department),
      searchTransparencyProject(name || badge, department),
      searchMappingPoliceViolence(name || badge, department)
    ]);

    // Combine results from external APIs
    externalSearches.forEach((result, index) => {
      if (result.status === 'fulfilled' && result.value.length > 0) {
        results = results.concat(result.value);
      }
    });

    // Remove duplicates and sort by relevance
    const uniqueResults = deduplicateOfficers(results);
    const sortedResults = uniqueResults
      .sort((a, b) => calculateRelevanceScore(b, name || badge) - calculateRelevanceScore(a, name || badge))
      .slice(0, parseInt(limit));

    // Filter by department if specified
    const filteredResults = department 
      ? sortedResults.filter(officer =>
          officer.department.toLowerCase().includes(department.toLowerCase()))
      : sortedResults;

    const response = {
      success: true,
      results: filteredResults.map(officer => ({
        ...officer,
        riskScore: calculateRiskScore(officer),
        dataSource: {
          name: officer.dataSource,
          reliability: officer.reliability,
          lastVerified: officer.lastUpdated,
          disclaimer: 'Information is based on publicly available records and may not be complete or current.'
        }
      })),
      searchCriteria: { badge, name, department },
      totalSources: Object.keys(POLICE_APIS).length + 1,
      timestamp: new Date().toISOString()
    };

    res.json(response);

  } catch (error) {
    console.error('Officer search error:', error);
    res.status(500).json({ 
      error: 'Failed to search officers',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get detailed officer information
router.get('/:badgeNumber', authenticateToken, (req, res) => {
  try {
    const { badgeNumber } = req.params;
    
    const officerKey = Object.keys(officerDatabase).find(key => 
      officerDatabase[key].badgeNumber === badgeNumber
    );

    if (!officerKey) {
      return res.status(404).json({ 
        error: 'Officer not found',
        message: 'No records found for the specified badge number'
      });
    }

    const officer = officerDatabase[officerKey];

    // Calculate statistics
    const totalComplaints = officer.complaints.length;
    const sustainedComplaints = officer.complaints.filter(c => c.status === 'Sustained').length;
    const totalCommendations = officer.commendations.length;

    const response = {
      success: true,
      officer: {
        ...officer,
        statistics: {
          totalComplaints,
          sustainedComplaints,
          totalCommendations,
          complaintRate: officer.yearsOfService > 0 ? (totalComplaints / officer.yearsOfService).toFixed(2) : '0.00'
        },
        dataSource: {
          name: 'Public Records Database',
          reliability: 'High',
          sources: [
            'Department Personnel Records',
            'Civilian Complaint Review Board',
            'Internal Affairs Division'
          ],
          disclaimer: 'Information is based on publicly available records. Some records may be sealed or expunged.'
        }
      },
      timestamp: new Date().toISOString()
    };

    res.json(response);

  } catch (error) {
    console.error('Get officer error:', error);
    res.status(500).json({ 
      error: 'Failed to get officer information',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Report officer interaction
router.post('/interaction', authenticateToken, [
  body('badgeNumber').isLength({ min: 1 }),
  body('officerName').optional().isLength({ min: 1 }),
  body('department').optional().isLength({ min: 1 }),
  body('interactionType').isIn(['traffic_stop', 'pedestrian_stop', 'arrest', 'investigation', 'other']),
  body('location').optional().isObject(),
  body('description').optional().isLength({ max: 1000 }),
  body('rating').optional().isInt({ min: 1, max: 5 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      badgeNumber,
      officerName,
      department,
      interactionType,
      location,
      description,
      rating
    } = req.body;

    // In production, this would be stored in a database
    const interaction = {
      id: Date.now().toString(),
      userId: req.user.userId,
      badgeNumber,
      officerName,
      department,
      interactionType,
      location,
      description,
      rating,
      timestamp: new Date().toISOString(),
      status: 'submitted'
    };

    // Mock storage
    console.log('Officer interaction reported:', interaction);

    res.status(201).json({
      success: true,
      message: 'Interaction reported successfully',
      interactionId: interaction.id,
      note: 'Your report has been recorded and may be used for transparency and accountability purposes.'
    });

  } catch (error) {
    console.error('Report interaction error:', error);
    res.status(500).json({ 
      error: 'Failed to report interaction',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get department statistics
router.get('/departments/:name/stats', authenticateToken, (req, res) => {
  try {
    const { name } = req.params;
    
    // Filter officers by department
    const departmentOfficers = Object.values(officerDatabase).filter(officer =>
      officer.department.toLowerCase().includes(name.toLowerCase())
    );

    if (departmentOfficers.length === 0) {
      return res.status(404).json({ 
        error: 'Department not found',
        message: 'No officers found for the specified department'
      });
    }

    // Calculate department statistics
    const totalOfficers = departmentOfficers.length;
    const totalComplaints = departmentOfficers.reduce((sum, officer) => sum + officer.complaints.length, 0);
    const totalCommendations = departmentOfficers.reduce((sum, officer) => sum + officer.commendations.length, 0);
    const avgYearsOfService = departmentOfficers.reduce((sum, officer) => sum + officer.yearsOfService, 0) / totalOfficers;

    const stats = {
      department: departmentOfficers[0].department,
      totalOfficers,
      totalComplaints,
      totalCommendations,
      avgYearsOfService: avgYearsOfService.toFixed(1),
      complaintRate: (totalComplaints / totalOfficers).toFixed(2),
      commendationRate: (totalCommendations / totalOfficers).toFixed(2),
      lastUpdated: new Date().toISOString()
    };

    res.json({
      success: true,
      statistics: stats,
      dataSource: {
        name: 'Public Records Database',
        reliability: 'High',
        disclaimer: 'Statistics are based on publicly available records. Some records may be sealed or expunged.'
      }
    });

  } catch (error) {
    console.error('Department stats error:', error);
    res.status(500).json({ 
      error: 'Failed to get department statistics',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Report community feedback on officer
router.post('/feedback', authenticateToken, [
  body('badgeNumber').isLength({ min: 1 }),
  body('rating').isInt({ min: 1, max: 5 }),
  body('comment').optional().isLength({ max: 1000 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      badgeNumber,
      rating,
      comment
    } = req.body;

    // In production, this would be stored in a database and linked to officer profiles
    const feedback = {
      id: Date.now().toString(),
      userId: req.user.userId,
      badgeNumber,
      rating,
      comment,
      timestamp: new Date().toISOString(),
      status: 'submitted'
    };

    console.log('Community feedback reported:', feedback);

    res.status(201).json({
      success: true,
      message: 'Feedback reported successfully',
      feedbackId: feedback.id,
      note: 'Your feedback has been recorded and will contribute to officer transparency.'
    });

  } catch (error) {
    console.error('Report feedback error:', error);
    res.status(500).json({ 
      error: 'Failed to report feedback',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Register device for push notifications
router.post('/notifications/register', authenticateToken, [
  body('deviceToken').isLength({ min: 1 }),
  body('platform').isIn(['ios', 'android'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      deviceToken,
      platform
    } = req.body;

    // In production, this would store the device token in a database
    console.log(`Device registered for notifications: ${deviceToken} on ${platform}`);

    res.status(200).json({
      success: true,
      message: 'Device registered for notifications successfully'
    });

  } catch (error) {
    console.error('Notification registration error:', error);
    res.status(500).json({ 
      error: 'Failed to register device for notifications',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Helper functions for external API searches

async function searchCPDP(query, department) {
  try {
    const params = new URLSearchParams({
      name: query,
      limit: '10'
    });
    if (department) params.append('current_unit__description', department);

    const response = await axios.get(`${POLICE_APIS.cpdp.baseUrl}/officers/?${params}`, {
      timeout: 10000,
      headers: { 'User-Agent': 'CopStopper/1.0' }
    });

    return (response.data.results || []).map(officer => ({
      id: officer.id?.toString() || '',
      badgeNumber: officer.current_badge?.toString() || '',
      name: `${officer.first_name || ''} ${officer.last_name || ''}`.trim(),
      department: officer.current_unit?.description || '',
      rank: officer.current_rank || '',
      yearsOfService: calculateYearsOfService(officer.appointed_date),
      complaints: parseComplaints(officer.complaint_records || []),
      commendations: parseCommendations(officer.awards || []),
      lastUpdated: new Date().toISOString(),
      dataSource: POLICE_APIS.cpdp.name,
      reliability: POLICE_APIS.cpdp.reliability
    }));
  } catch (error) {
    console.error('CPDP search error:', error.message);
    return [];
  }
}

async function searchPoliceDataInitiative(query, department) {
  try {
    const params = new URLSearchParams({
      q: query,
      limit: '10'
    });
    if (department) params.append('department', department);

    const response = await axios.get(`${POLICE_APIS.policeDataInitiative.baseUrl}/officers/search?${params}`, {
      timeout: 10000,
      headers: { 'User-Agent': 'CopStopper/1.0' }
    });

    return (response.data.officers || []).map(officer => ({
      id: officer.id?.toString() || '',
      badgeNumber: officer.badge_number?.toString() || '',
      name: officer.name || '',
      department: officer.department || '',
      rank: officer.rank || '',
      yearsOfService: officer.years_of_service || 0,
      complaints: parseComplaints(officer.complaints || []),
      commendations: parseCommendations(officer.commendations || []),
      lastUpdated: new Date().toISOString(),
      dataSource: POLICE_APIS.policeDataInitiative.name,
      reliability: POLICE_APIS.policeDataInitiative.reliability
    }));
  } catch (error) {
    console.error('Police Data Initiative search error:', error.message);
    return [];
  }
}

async function searchTransparencyProject(query, department) {
  try {
    const params = new URLSearchParams({
      name: query,
      limit: '10'
    });
    if (department) params.append('agency', department);

    const response = await axios.get(`${POLICE_APIS.transparencyProject.baseUrl}/officers?${params}`, {
      timeout: 10000,
      headers: { 'User-Agent': 'CopStopper/1.0' }
    });

    return (response.data.data || []).map(officer => ({
      id: officer.uid?.toString() || '',
      badgeNumber: officer.badge_no?.toString() || '',
      name: officer.name || '',
      department: officer.agency || '',
      rank: officer.rank || '',
      yearsOfService: calculateYearsOfService(officer.hire_date),
      complaints: parseComplaints(officer.complaints || []),
      commendations: parseCommendations(officer.commendations || []),
      lastUpdated: new Date().toISOString(),
      dataSource: POLICE_APIS.transparencyProject.name,
      reliability: POLICE_APIS.transparencyProject.reliability
    }));
  } catch (error) {
    console.error('Transparency Project search error:', error.message);
    return [];
  }
}

async function searchMappingPoliceViolence(query, department) {
  try {
    const params = new URLSearchParams({
      search: query,
      limit: '10'
    });
    if (department) params.append('department', department);

    const response = await axios.get(`${POLICE_APIS.mappingPoliceViolence.baseUrl}/officers?${params}`, {
      timeout: 10000,
      headers: { 'User-Agent': 'CopStopper/1.0' }
    });

    return (response.data.officers || []).map(officer => ({
      id: officer.id?.toString() || '',
      badgeNumber: officer.badge_number?.toString() || '',
      name: officer.officer_name || '',
      department: officer.department || '',
      rank: officer.rank || '',
      yearsOfService: officer.years_on_force || 0,
      complaints: parseComplaints(officer.incidents || []),
      commendations: [],
      lastUpdated: new Date().toISOString(),
      dataSource: POLICE_APIS.mappingPoliceViolence.name,
      reliability: POLICE_APIS.mappingPoliceViolence.reliability
    }));
  } catch (error) {
    console.error('Mapping Police Violence search error:', error.message);
    return [];
  }
}

function parseComplaints(complaints) {
  return complaints.map(complaint => ({
    id: complaint.id?.toString() || complaint.cr_id?.toString() || '',
    date: complaint.date || complaint.incident_date || null,
    type: complaint.type || complaint.category || complaint.allegation || 'Unknown',
    description: complaint.description || complaint.summary || '',
    status: complaint.status || complaint.final_finding || complaint.disposition || 'Unknown',
    outcome: complaint.outcome || complaint.final_outcome || complaint.action_taken || ''
  }));
}

function parseCommendations(commendations) {
  return commendations.map(commendation => ({
    id: commendation.id?.toString() || '',
    date: commendation.date || commendation.start_date || null,
    type: commendation.type || commendation.award_type || 'Recognition',
    description: commendation.description || commendation.reason || commendation.award_type || ''
  }));
}

function calculateYearsOfService(hireDateStr) {
  if (!hireDateStr) return 0;
  
  try {
    const hireDate = new Date(hireDateStr);
    const now = new Date();
    return Math.floor((now - hireDate) / (365.25 * 24 * 60 * 60 * 1000));
  } catch (error) {
    return 0;
  }
}

function deduplicateOfficers(officers) {
  const seen = new Set();
  return officers.filter(officer => {
    const key = `${officer.badgeNumber}_${officer.department}`;
    if (seen.has(key)) {
      return false;
    }
    seen.add(key);
    return true;
  });
}

function calculateRelevanceScore(officer, query) {
  let score = 0;
  const queryLower = query.toLowerCase();
  
  // Name match
  if (officer.name.toLowerCase().includes(queryLower)) {
    score += 10;
  }
  
  // Badge number match
  if (officer.badgeNumber.toLowerCase().includes(queryLower)) {
    score += 15;
  }
  
  // Department match
  if (officer.department.toLowerCase().includes(queryLower)) {
    score += 5;
  }
  
  // Data completeness
  score += (officer.complaints?.length || 0) * 0.5;
  score += (officer.commendations?.length || 0) * 0.3;
  
  // Data source reliability
  score += officer.reliability * 5;
  
  return score;
}

function calculateRiskScore(officer) {
  let score = 0;
  
  // Base score from complaint rate
  if (officer.yearsOfService > 0) {
    score += ((officer.complaints?.length || 0) / officer.yearsOfService) * 10;
  }
  
  // Higher weight for sustained complaints
  const sustainedComplaints = (officer.complaints || []).filter(c => 
    c.status.toLowerCase().includes('sustained') ||
    c.status.toLowerCase().includes('founded')
  );
  score += sustainedComplaints.length * 5;
  
  // Recent complaints are weighted more heavily
  const oneYearAgo = new Date();
  oneYearAgo.setFullYear(oneYearAgo.getFullYear() - 1);
  
  const recentComplaints = (officer.complaints || []).filter(c => 
    c.date && new Date(c.date) > oneYearAgo
  );
  score += recentComplaints.length * 3;
  
  // Commendations reduce risk score
  score -= (officer.commendations?.length || 0) * 2;
  
  return Math.max(0, Math.min(100, score));
}

module.exports = router;