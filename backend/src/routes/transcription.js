const express = require('express');
const axios = require('axios');
const multer = require('multer');
const { body, validationResult } = require('express-validator');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Configure multer for audio file uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 25 * 1024 * 1024, // 25MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('audio/')) {
      cb(null, true);
    } else {
      cb(new Error('Only audio files are allowed'), false);
    }
  }
});

// Transcribe audio using OpenAI Whisper
router.post('/transcribe', authenticateToken, upload.single('audio'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Audio file is required' });
    }

    const { language = 'en', model = 'whisper-1' } = req.body;

    // Prepare form data for OpenAI API
    const formData = new FormData();
    formData.append('file', new Blob([req.file.buffer]), req.file.originalname);
    formData.append('model', model);
    formData.append('language', language);
    formData.append('response_format', 'verbose_json');

    // Call OpenAI Whisper API
    const response = await axios.post('https://api.openai.com/v1/audio/transcriptions', formData, {
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        'Content-Type': 'multipart/form-data'
      },
      timeout: 60000 // 60 second timeout
    });

    const transcription = response.data;

    // Process segments for better structure
    const segments = transcription.segments?.map(segment => ({
      id: segment.id,
      start: segment.start,
      end: segment.end,
      text: segment.text.trim(),
      confidence: segment.avg_logprob ? Math.exp(segment.avg_logprob) : 0.8
    })) || [];

    // Calculate overall confidence
    const overallConfidence = segments.length > 0 
      ? segments.reduce((sum, seg) => sum + seg.confidence, 0) / segments.length
      : 0.8;

    const result = {
      text: transcription.text,
      language: transcription.language || language,
      duration: transcription.duration,
      confidence: overallConfidence,
      segments,
      timestamp: new Date().toISOString(),
      userId: req.user.userId
    };

    res.json({
      success: true,
      transcription: result
    });

  } catch (error) {
    console.error('Transcription error:', error);
    
    if (error.response?.status === 401) {
      return res.status(401).json({ error: 'Invalid OpenAI API key' });
    }
    
    if (error.response?.status === 429) {
      return res.status(429).json({ error: 'Rate limit exceeded. Please try again later.' });
    }

    res.status(500).json({ 
      error: 'Transcription failed',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Real-time transcription stream (WebSocket would be better for production)
router.post('/stream', authenticateToken, upload.single('audio'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Audio chunk is required' });
    }

    // For demo purposes, we'll use the same transcription endpoint
    // In production, you'd want to implement proper streaming
    const { language = 'en' } = req.body;

    const formData = new FormData();
    formData.append('file', new Blob([req.file.buffer]), 'chunk.wav');
    formData.append('model', 'whisper-1');
    formData.append('language', language);

    const response = await axios.post('https://api.openai.com/v1/audio/transcriptions', formData, {
      headers: {
        'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
        'Content-Type': 'multipart/form-data'
      },
      timeout: 30000
    });

    res.json({
      success: true,
      text: response.data.text,
      isPartial: true,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    console.error('Stream transcription error:', error);
    res.status(500).json({ 
      error: 'Stream transcription failed',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get transcription history
router.get('/history', authenticateToken, (req, res) => {
  // In production, this would query a database
  // For now, return mock data
  const mockHistory = [
    {
      id: '1',
      text: 'Officer, I understand you pulled me over. May I ask what the reason was?',
      timestamp: new Date(Date.now() - 3600000).toISOString(),
      confidence: 0.95,
      duration: 4.2
    },
    {
      id: '2', 
      text: 'I am recording this interaction for my safety and yours.',
      timestamp: new Date(Date.now() - 7200000).toISOString(),
      confidence: 0.92,
      duration: 3.8
    }
  ];

  res.json({
    success: true,
    history: mockHistory,
    total: mockHistory.length
  });
});

module.exports = router;