const express = require('express');
const router = express.Router();

// @route   POST api/collaborative/session
// @desc    Create a new collaborative session
// @access  Private
router.post('/session', (req, res) => {
  res.json({ msg: 'Session created' });
});

// @route   POST api/collaborative/session/:id/join
// @desc    Join a collaborative session
// @access  Private
router.post('/session/:id/join', (req, res) => {
  res.json({ msg: 'Session joined' });
});

// @route   POST api/collaborative/session/:id/leave
// @desc    Leave a collaborative session
// @access  Private
router.post('/session/:id/leave', (req, res) => {
  res.json({ msg: 'Session left' });
});

module.exports = router;
