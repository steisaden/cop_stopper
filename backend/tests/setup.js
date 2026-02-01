const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

// Test database configuration
const testDbConfig = {
  user: process.env.TEST_DB_USER || 'postgres',
  host: process.env.TEST_DB_HOST || 'localhost',
  database: process.env.TEST_DB_NAME || 'cop_stopper_test',
  password: process.env.TEST_DB_PASSWORD || 'password',
  port: process.env.TEST_DB_PORT || 5432,
};

let testPool;

// Setup test database
const setupTestDatabase = async () => {
  try {
    // Create test database pool
    testPool = new Pool(testDbConfig);

    // Read and execute schema
    const schemaPath = path.join(__dirname, '../src/database/schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    await testPool.query(schema);

    console.log('Test database setup completed');
    return testPool;
  } catch (err) {
    console.error('Test database setup failed:', err);
    throw err;
  }
};

// Clean test database
const cleanTestDatabase = async () => {
  try {
    if (testPool) {
      // Drop all tables
      await testPool.query(`
        DROP SCHEMA public CASCADE;
        CREATE SCHEMA public;
        GRANT ALL ON SCHEMA public TO postgres;
        GRANT ALL ON SCHEMA public TO public;
      `);
      
      // Recreate schema
      const schemaPath = path.join(__dirname, '../src/database/schema.sql');
      const schema = fs.readFileSync(schemaPath, 'utf8');
      await testPool.query(schema);
    }
  } catch (err) {
    console.error('Test database cleanup failed:', err);
    throw err;
  }
};

// Teardown test database
const teardownTestDatabase = async () => {
  try {
    if (testPool) {
      await testPool.end();
      testPool = null;
    }
  } catch (err) {
    console.error('Test database teardown failed:', err);
  }
};

// Create test user
const createTestUser = async (userData = {}) => {
  const bcrypt = require('bcryptjs');
  
  const defaultUser = {
    email: 'test@example.com',
    password: 'testpassword123',
    firstName: 'Test',
    lastName: 'User',
    phone: '+1234567890'
  };

  const user = { ...defaultUser, ...userData };
  const passwordHash = await bcrypt.hash(user.password, 12);

  const result = await testPool.query(
    `INSERT INTO users (email, password_hash, first_name, last_name, phone, email_verified)
     VALUES ($1, $2, $3, $4, $5, true)
     RETURNING id, email, first_name, last_name, created_at`,
    [user.email, passwordHash, user.firstName, user.lastName, user.phone]
  );

  // Create user settings
  await testPool.query(
    'INSERT INTO user_settings (user_id) VALUES ($1)',
    [result.rows[0].id]
  );

  return {
    ...result.rows[0],
    password: user.password // Return plain password for testing
  };
};

// Create test recording session
const createTestRecordingSession = async (userId, sessionData = {}) => {
  const defaultSession = {
    title: 'Test Recording Session',
    description: 'Test session for automated testing',
    startTime: new Date(),
    duration: 300, // 5 minutes
    videoQuality: '1080p',
    audioBitrate: 128,
    locationLat: 40.7128,
    locationLng: -74.0060,
    locationAddress: 'New York, NY',
    jurisdiction: 'New York',
    isEmergency: false
  };

  const session = { ...defaultSession, ...sessionData };

  const result = await testPool.query(
    `INSERT INTO recording_sessions 
     (user_id, title, description, start_time, duration, video_quality, audio_bitrate,
      location_lat, location_lng, location_address, jurisdiction, is_emergency)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)
     RETURNING *`,
    [
      userId, session.title, session.description, session.startTime,
      session.duration, session.videoQuality, session.audioBitrate,
      session.locationLat, session.locationLng, session.locationAddress,
      session.jurisdiction, session.isEmergency
    ]
  );

  return result.rows[0];
};

// Create test officer profile
const createTestOfficer = async (officerData = {}) => {
  const defaultOfficer = {
    badgeNumber: 'TEST001',
    firstName: 'John',
    lastName: 'Officer',
    department: 'Test Police Department',
    rank: 'Officer',
    yearsOfService: 5
  };

  const officer = { ...defaultOfficer, ...officerData };

  const result = await testPool.query(
    `INSERT INTO officer_profiles 
     (badge_number, first_name, last_name, department, rank, years_of_service)
     VALUES ($1, $2, $3, $4, $5, $6)
     RETURNING *`,
    [
      officer.badgeNumber, officer.firstName, officer.lastName,
      officer.department, officer.rank, officer.yearsOfService
    ]
  );

  return result.rows[0];
};

// Mock external services
const mockExternalServices = () => {
  // Mock OpenAI API
  jest.mock('openai', () => ({
    OpenAI: jest.fn().mockImplementation(() => ({
      audio: {
        transcriptions: {
          create: jest.fn().mockResolvedValue({
            text: 'This is a mock transcription of the audio file.'
          })
        }
      },
      chat: {
        completions: {
          create: jest.fn().mockResolvedValue({
            choices: [{
              message: {
                content: JSON.stringify({
                  status: 'verified',
                  confidence: 0.85,
                  explanation: 'This is a mock fact-check result.'
                })
              }
            }]
          })
        }
      }
    }))
  }));

  // Mock Google Maps API
  jest.mock('@googlemaps/google-maps-services-js', () => ({
    Client: jest.fn().mockImplementation(() => ({
      reverseGeocode: jest.fn().mockResolvedValue({
        data: {
          results: [{
            formatted_address: 'Mock Address, Mock City, Mock State 12345'
          }]
        }
      })
    }))
  }));
};

module.exports = {
  setupTestDatabase,
  cleanTestDatabase,
  teardownTestDatabase,
  createTestUser,
  createTestRecordingSession,
  createTestOfficer,
  mockExternalServices,
  testPool: () => testPool
};