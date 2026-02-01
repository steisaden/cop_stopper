const express = require('express');
const multer = require('multer');
const { body, validationResult } = require('express-validator');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Configure multer for recording uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('audio/') || file.mimetype.startsWith('video/')) {
      cb(null, true);
    } else {
      cb(new Error('Only audio and video files are allowed'), false);
    }
  }
});

// Mock recording storage
const recordings = new Map();

// Upload recording
router.post('/upload', authenticateToken, upload.single('recording'), [
  body('title').optional().isLength({ min: 1, max: 200 }),
  body('description').optional().isLength({ max: 1000 }),
  body('latitude').optional().isFloat({ min: -90, max: 90 }),
  body('longitude').optional().isFloat({ min: -180, max: 180 }),
  body('duration').isFloat({ min: 0 }),
  body('recordingType').isIn(['audio', 'video'])
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'Recording file is required' });
    }

    const {
      title,
      description,
      latitude,
      longitude,
      duration,
      recordingType
    } = req.body;

    const recordingId = Date.now().toString();
    const recording = {
      id: recordingId,
      userId: req.user.userId,
      title: title || `Recording ${new Date().toLocaleDateString()}`,
      description,
      filename: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
      duration: parseFloat(duration),
      type: recordingType,
      location: latitude && longitude ? { latitude: parseFloat(latitude), longitude: parseFloat(longitude) } : null,
      uploadedAt: new Date().toISOString(),
      isEncrypted: true,
      status: 'processing'
    };

    // In production, you would:
    // 1. Encrypt the file
    // 2. Store it in secure cloud storage (AWS S3, etc.)
    // 3. Save metadata to database
    // 4. Generate secure access URLs

    recordings.set(recordingId, {
      ...recording,
      buffer: req.file.buffer // In production, this would be a secure storage reference
    });

    // Simulate processing delay
    setTimeout(() => {
      const storedRecording = recordings.get(recordingId);
      if (storedRecording) {
        storedRecording.status = 'ready';
      }
    }, 2000);

    res.status(201).json({
      success: true,
      recording: {
        id: recording.id,
        title: recording.title,
        description: recording.description,
        duration: recording.duration,
        type: recording.type,
        location: recording.location,
        uploadedAt: recording.uploadedAt,
        status: recording.status
      }
    });

  } catch (error) {
    console.error('Recording upload error:', error);
    res.status(500).json({ 
      error: 'Failed to upload recording',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get user recordings
router.get('/', authenticateToken, (req, res) => {
  try {
    const { page = 1, limit = 10, type } = req.query;
    const userId = req.user.userId;

    // Filter recordings by user
    const userRecordings = Array.from(recordings.values())
      .filter(recording => recording.userId === userId)
      .filter(recording => !type || recording.type === type)
      .sort((a, b) => new Date(b.uploadedAt) - new Date(a.uploadedAt));

    // Pagination
    const startIndex = (page - 1) * limit;
    const endIndex = startIndex + parseInt(limit);
    const paginatedRecordings = userRecordings.slice(startIndex, endIndex);

    // Remove sensitive data
    const safeRecordings = paginatedRecordings.map(recording => ({
      id: recording.id,
      title: recording.title,
      description: recording.description,
      duration: recording.duration,
      type: recording.type,
      location: recording.location,
      uploadedAt: recording.uploadedAt,
      status: recording.status,
      size: recording.size
    }));

    res.json({
      success: true,
      recordings: safeRecordings,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: userRecordings.length,
        pages: Math.ceil(userRecordings.length / limit)
      }
    });

  } catch (error) {
    console.error('Get recordings error:', error);
    res.status(500).json({ 
      error: 'Failed to get recordings',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get specific recording
router.get('/:id', authenticateToken, (req, res) => {
  try {
    const { id } = req.params;
    const recording = recordings.get(id);

    if (!recording) {
      return res.status(404).json({ error: 'Recording not found' });
    }

    if (recording.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    res.json({
      success: true,
      recording: {
        id: recording.id,
        title: recording.title,
        description: recording.description,
        duration: recording.duration,
        type: recording.type,
        location: recording.location,
        uploadedAt: recording.uploadedAt,
        status: recording.status,
        size: recording.size,
        filename: recording.filename
      }
    });

  } catch (error) {
    console.error('Get recording error:', error);
    res.status(500).json({ 
      error: 'Failed to get recording',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Download recording
router.get('/:id/download', authenticateToken, (req, res) => {
  try {
    const { id } = req.params;
    const recording = recordings.get(id);

    if (!recording) {
      return res.status(404).json({ error: 'Recording not found' });
    }

    if (recording.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (recording.status !== 'ready') {
      return res.status(202).json({ 
        error: 'Recording is still processing',
        status: recording.status
      });
    }

    // Set appropriate headers
    res.setHeader('Content-Type', recording.mimetype);
    res.setHeader('Content-Disposition', `attachment; filename="${recording.filename}"`);
    res.setHeader('Content-Length', recording.size);

    // In production, you would stream from secure storage
    res.send(recording.buffer);

  } catch (error) {
    console.error('Download recording error:', error);
    res.status(500).json({ 
      error: 'Failed to download recording',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Delete recording
router.delete('/:id', authenticateToken, (req, res) => {
  try {
    const { id } = req.params;
    const recording = recordings.get(id);

    if (!recording) {
      return res.status(404).json({ error: 'Recording not found' });
    }

    if (recording.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // In production, you would also delete from secure storage
    recordings.delete(id);

    res.json({
      success: true,
      message: 'Recording deleted successfully'
    });

  } catch (error) {
    console.error('Delete recording error:', error);
    res.status(500).json({ 
      error: 'Failed to delete recording',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;