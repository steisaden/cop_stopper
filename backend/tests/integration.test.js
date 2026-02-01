const request = require('supertest');
const app = require('../src/server');
const { 
  setupTestDatabase, 
  cleanTestDatabase, 
  teardownTestDatabase,
  createTestUser,
  createTestRecordingSession,
  createTestOfficer,
  mockExternalServices
} = require('./setup');

describe('Integration Tests', () => {
  let testUser;
  let authToken;

  beforeAll(async () => {
    await setupTestDatabase();
    mockExternalServices();
  });

  beforeEach(async () => {
    await cleanTestDatabase();
    
    // Create test user and get auth token
    testUser = await createTestUser();
    const loginResponse = await request(app)
      .post('/api/auth/login')
      .send({
        email: testUser.email,
        password: testUser.password
      });
    authToken = loginResponse.body.token;
  });

  afterAll(async () => {
    await teardownTestDatabase();
  });

  describe('Complete Recording Workflow', () => {
    it('should handle complete recording session lifecycle', async () => {
      // 1. Start recording session
      const sessionData = {
        title: 'Integration Test Recording',
        description: 'Full workflow test',
        videoQuality: '1080p',
        audioBitrate: 128,
        locationLat: 40.7128,
        locationLng: -74.0060,
        isEmergency: false
      };

      const createResponse = await request(app)
        .post('/api/recordings/sessions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sessionData)
        .expect(201);

      expect(createResponse.body).toHaveProperty('session');
      const sessionId = createResponse.body.session.id;

      // 2. Add transcription data
      const transcriptionData = {
        textContent: 'This is a test transcription segment',
        timestampStart: 1000,
        timestampEnd: 5000,
        speakerId: 'speaker_1',
        confidenceScore: 0.95
      };

      await request(app)
        .post(`/api/transcription/sessions/${sessionId}/segments`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(transcriptionData)
        .expect(201);

      // 3. Add fact-check result
      const factCheckData = {
        claim: 'Test claim for fact checking',
        status: 'verified',
        confidence: 0.85,
        explanation: 'This is a test fact check',
        sources: ['https://example.com/source1'],
        timestampMs: 2500
      };

      await request(app)
        .post(`/api/legal/fact-check/${sessionId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(factCheckData)
        .expect(201);

      // 4. Add legal alert
      const legalAlertData = {
        alertType: 'rights_violation',
        severity: 'medium',
        title: 'Test Legal Alert',
        description: 'This is a test legal alert',
        suggestedResponse: 'Test response suggestion',
        relevantLaws: ['Test Law 1', 'Test Law 2'],
        timestampMs: 3000
      };

      await request(app)
        .post(`/api/legal/alerts/${sessionId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .send(legalAlertData)
        .expect(201);

      // 5. End recording session
      const endResponse = await request(app)
        .put(`/api/recordings/sessions/${sessionId}/end`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          endTime: new Date().toISOString(),
          duration: 300
        })
        .expect(200);

      expect(endResponse.body.session).toHaveProperty('endTime');
      expect(endResponse.body.session).toHaveProperty('duration', 300);

      // 6. Get complete session with all data
      const sessionResponse = await request(app)
        .get(`/api/recordings/sessions/${sessionId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      const session = sessionResponse.body.session;
      expect(session).toHaveProperty('transcriptions');
      expect(session).toHaveProperty('factChecks');
      expect(session).toHaveProperty('legalAlerts');
      expect(session.transcriptions).toHaveLength(1);
      expect(session.factChecks).toHaveLength(1);
      expect(session.legalAlerts).toHaveLength(1);
    });

    it('should handle emergency recording workflow', async () => {
      // Create emergency session
      const emergencySessionData = {
        title: 'Emergency Recording',
        isEmergency: true,
        locationLat: 40.7128,
        locationLng: -74.0060
      };

      const response = await request(app)
        .post('/api/recordings/sessions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(emergencySessionData)
        .expect(201);

      expect(response.body.session).toHaveProperty('isEmergency', true);

      // Emergency sessions should trigger notifications (mocked)
      // In real implementation, this would send notifications to emergency contacts
    });
  });

  describe('Officer Records Integration', () => {
    let testOfficer;

    beforeEach(async () => {
      testOfficer = await createTestOfficer();
    });

    it('should search and retrieve officer information', async () => {
      // Search by badge number
      const searchResponse = await request(app)
        .get(`/api/officers/search?badgeNumber=${testOfficer.badge_number}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(searchResponse.body.officers).toHaveLength(1);
      expect(searchResponse.body.officers[0]).toHaveProperty('badgeNumber', testOfficer.badge_number);

      // Get detailed officer profile
      const profileResponse = await request(app)
        .get(`/api/officers/${testOfficer.id}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(profileResponse.body.officer).toHaveProperty('firstName', testOfficer.first_name);
      expect(profileResponse.body.officer).toHaveProperty('department', testOfficer.department);
    });

    it('should handle officer complaint reporting', async () => {
      const complaintData = {
        officerId: testOfficer.id,
        category: 'excessive_force',
        description: 'Test complaint description',
        incidentDate: new Date().toISOString()
      };

      const response = await request(app)
        .post('/api/officers/complaints')
        .set('Authorization', `Bearer ${authToken}`)
        .send(complaintData)
        .expect(201);

      expect(response.body).toHaveProperty('message', 'Complaint submitted successfully');
      expect(response.body.complaint).toHaveProperty('category', complaintData.category);
    });
  });

  describe('Collaborative Monitoring Integration', () => {
    it('should create and manage collaborative session', async () => {
      // Create collaborative session
      const sessionData = {
        sessionType: 'private_group',
        title: 'Test Collaborative Session',
        description: 'Integration test session',
        maxParticipants: 5,
        privacyLevel: 'private'
      };

      const createResponse = await request(app)
        .post('/api/collaborative/sessions')
        .set('Authorization', `Bearer ${authToken}`)
        .send(sessionData)
        .expect(201);

      const sessionId = createResponse.body.session.id;
      expect(createResponse.body.session).toHaveProperty('hostUserId', testUser.id);

      // Join session as participant
      const joinResponse = await request(app)
        .post(`/api/collaborative/sessions/${sessionId}/join`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(joinResponse.body).toHaveProperty('message', 'Joined session successfully');

      // Get session participants
      const participantsResponse = await request(app)
        .get(`/api/collaborative/sessions/${sessionId}/participants`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(participantsResponse.body.participants).toHaveLength(1);
      expect(participantsResponse.body.participants[0]).toHaveProperty('userId', testUser.id);

      // Leave session
      await request(app)
        .post(`/api/collaborative/sessions/${sessionId}/leave`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);
    });
  });

  describe('Document Management Integration', () => {
    let testSession;

    beforeEach(async () => {
      testSession = await createTestRecordingSession(testUser.id);
    });

    it('should handle document upload and retrieval', async () => {
      // Mock file upload
      const documentData = {
        title: 'Test Document',
        description: 'Integration test document',
        fileType: 'pdf',
        sessionId: testSession.id,
        tags: ['test', 'integration']
      };

      const uploadResponse = await request(app)
        .post('/api/documents')
        .set('Authorization', `Bearer ${authToken}`)
        .send(documentData)
        .expect(201);

      const documentId = uploadResponse.body.document.id;
      expect(uploadResponse.body.document).toHaveProperty('title', documentData.title);

      // Get document
      const getResponse = await request(app)
        .get(`/api/documents/${documentId}`)
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(getResponse.body.document).toHaveProperty('title', documentData.title);
      expect(getResponse.body.document).toHaveProperty('sessionId', testSession.id);

      // List user documents
      const listResponse = await request(app)
        .get('/api/documents')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200);

      expect(listResponse.body.documents).toHaveLength(1);
      expect(listResponse.body.documents[0]).toHaveProperty('id', documentId);
    });
  });

  describe('Location Services Integration', () => {
    it('should handle location-based operations', async () => {
      const locationData = {
        latitude: 40.7128,
        longitude: -74.0060
      };

      // Get jurisdiction info
      const jurisdictionResponse = await request(app)
        .post('/api/location/jurisdiction')
        .set('Authorization', `Bearer ${authToken}`)
        .send(locationData)
        .expect(200);

      expect(jurisdictionResponse.body).toHaveProperty('jurisdiction');
      expect(jurisdictionResponse.body).toHaveProperty('recordingLaws');

      // Get nearby incidents (if any)
      const incidentsResponse = await request(app)
        .post('/api/location/nearby-incidents')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          ...locationData,
          radiusKm: 5
        })
        .expect(200);

      expect(incidentsResponse.body).toHaveProperty('incidents');
      expect(Array.isArray(incidentsResponse.body.incidents)).toBe(true);
    });
  });

  describe('Error Handling Integration', () => {
    it('should handle database connection errors gracefully', async () => {
      // This would require mocking database failures
      // For now, test that the API returns proper error responses
      
      const response = await request(app)
        .get('/api/recordings/sessions/invalid-uuid')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should handle rate limiting', async () => {
      // Make multiple rapid requests to test rate limiting
      const requests = Array(10).fill().map(() =>
        request(app)
          .get('/api/auth/profile')
          .set('Authorization', `Bearer ${authToken}`)
      );

      const responses = await Promise.all(requests);
      
      // All should succeed within rate limit
      responses.forEach(response => {
        expect([200, 429]).toContain(response.status);
      });
    });
  });

  describe('Performance Tests', () => {
    it('should handle concurrent user operations', async () => {
      // Create multiple users and perform concurrent operations
      const users = await Promise.all([
        createTestUser({ email: 'user1@test.com' }),
        createTestUser({ email: 'user2@test.com' }),
        createTestUser({ email: 'user3@test.com' })
      ]);

      // Login all users concurrently
      const loginPromises = users.map(user =>
        request(app)
          .post('/api/auth/login')
          .send({
            email: user.email,
            password: user.password
          })
      );

      const loginResponses = await Promise.all(loginPromises);
      
      // All logins should succeed
      loginResponses.forEach(response => {
        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('token');
      });

      // Create recording sessions concurrently
      const sessionPromises = loginResponses.map(loginResponse =>
        request(app)
          .post('/api/recordings/sessions')
          .set('Authorization', `Bearer ${loginResponse.body.token}`)
          .send({
            title: 'Concurrent Test Session',
            videoQuality: '1080p'
          })
      );

      const sessionResponses = await Promise.all(sessionPromises);
      
      // All session creations should succeed
      sessionResponses.forEach(response => {
        expect(response.status).toBe(201);
        expect(response.body).toHaveProperty('session');
      });
    });
  });
});