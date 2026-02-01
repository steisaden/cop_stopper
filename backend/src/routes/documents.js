const express = require('express');
const multer = require('multer');
const { body, validationResult } = require('express-validator');
const { authenticateToken } = require('../middleware/auth');
const router = express.Router();

// Configure multer for document uploads
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only JPEG, PNG, WebP, and PDF files are allowed'), false);
    }
  }
});

// Mock document storage
const documents = new Map();

// Upload document
router.post('/upload', authenticateToken, upload.single('document'), [
  body('title').isLength({ min: 1, max: 200 }),
  body('type').isIn(['license', 'registration', 'insurance', 'id', 'other']),
  body('description').optional().isLength({ max: 500 }),
  body('expirationDate').optional().isISO8601()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    if (!req.file) {
      return res.status(400).json({ error: 'Document file is required' });
    }

    const { title, type, description, expirationDate } = req.body;

    const documentId = Date.now().toString();
    const document = {
      id: documentId,
      userId: req.user.userId,
      title,
      type,
      description,
      filename: req.file.originalname,
      mimetype: req.file.mimetype,
      size: req.file.size,
      expirationDate: expirationDate ? new Date(expirationDate).toISOString() : null,
      uploadedAt: new Date().toISOString(),
      isEncrypted: true,
      accessCount: 0,
      lastAccessed: null
    };

    // In production, you would:
    // 1. Encrypt the document
    // 2. Store it in secure cloud storage
    // 3. Save metadata to database
    // 4. Set up expiration monitoring

    documents.set(documentId, {
      ...document,
      buffer: req.file.buffer // In production, this would be a secure storage reference
    });

    res.status(201).json({
      success: true,
      document: {
        id: document.id,
        title: document.title,
        type: document.type,
        description: document.description,
        expirationDate: document.expirationDate,
        uploadedAt: document.uploadedAt,
        size: document.size
      }
    });

  } catch (error) {
    console.error('Document upload error:', error);
    res.status(500).json({ 
      error: 'Failed to upload document',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get user documents
router.get('/', authenticateToken, (req, res) => {
  try {
    const { type, expiring } = req.query;
    const userId = req.user.userId;

    // Filter documents by user
    let userDocuments = Array.from(documents.values())
      .filter(document => document.userId === userId);

    // Filter by type if specified
    if (type) {
      userDocuments = userDocuments.filter(document => document.type === type);
    }

    // Filter expiring documents (within 30 days)
    if (expiring === 'true') {
      const thirtyDaysFromNow = new Date();
      thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);
      
      userDocuments = userDocuments.filter(document => 
        document.expirationDate && 
        new Date(document.expirationDate) <= thirtyDaysFromNow
      );
    }

    // Sort by upload date (newest first)
    userDocuments.sort((a, b) => new Date(b.uploadedAt) - new Date(a.uploadedAt));

    // Remove sensitive data
    const safeDocuments = userDocuments.map(document => {
      const daysUntilExpiration = document.expirationDate 
        ? Math.ceil((new Date(document.expirationDate) - new Date()) / (1000 * 60 * 60 * 24))
        : null;

      return {
        id: document.id,
        title: document.title,
        type: document.type,
        description: document.description,
        expirationDate: document.expirationDate,
        daysUntilExpiration,
        uploadedAt: document.uploadedAt,
        size: document.size,
        accessCount: document.accessCount,
        lastAccessed: document.lastAccessed,
        isExpired: daysUntilExpiration !== null && daysUntilExpiration < 0,
        isExpiringSoon: daysUntilExpiration !== null && daysUntilExpiration <= 30 && daysUntilExpiration >= 0
      };
    });

    res.json({
      success: true,
      documents: safeDocuments,
      summary: {
        total: safeDocuments.length,
        expiring: safeDocuments.filter(doc => doc.isExpiringSoon).length,
        expired: safeDocuments.filter(doc => doc.isExpired).length
      }
    });

  } catch (error) {
    console.error('Get documents error:', error);
    res.status(500).json({ 
      error: 'Failed to get documents',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get specific document
router.get('/:id', authenticateToken, (req, res) => {
  try {
    const { id } = req.params;
    const document = documents.get(id);

    if (!document) {
      return res.status(404).json({ error: 'Document not found' });
    }

    if (document.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Update access tracking
    document.accessCount += 1;
    document.lastAccessed = new Date().toISOString();

    const daysUntilExpiration = document.expirationDate 
      ? Math.ceil((new Date(document.expirationDate) - new Date()) / (1000 * 60 * 60 * 24))
      : null;

    res.json({
      success: true,
      document: {
        id: document.id,
        title: document.title,
        type: document.type,
        description: document.description,
        expirationDate: document.expirationDate,
        daysUntilExpiration,
        uploadedAt: document.uploadedAt,
        size: document.size,
        filename: document.filename,
        accessCount: document.accessCount,
        lastAccessed: document.lastAccessed,
        isExpired: daysUntilExpiration !== null && daysUntilExpiration < 0,
        isExpiringSoon: daysUntilExpiration !== null && daysUntilExpiration <= 30 && daysUntilExpiration >= 0
      }
    });

  } catch (error) {
    console.error('Get document error:', error);
    res.status(500).json({ 
      error: 'Failed to get document',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// View/download document
router.get('/:id/view', authenticateToken, (req, res) => {
  try {
    const { id } = req.params;
    const { download = 'false' } = req.query;
    const document = documents.get(id);

    if (!document) {
      return res.status(404).json({ error: 'Document not found' });
    }

    if (document.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Update access tracking
    document.accessCount += 1;
    document.lastAccessed = new Date().toISOString();

    // Set appropriate headers
    res.setHeader('Content-Type', document.mimetype);
    
    if (download === 'true') {
      res.setHeader('Content-Disposition', `attachment; filename="${document.filename}"`);
    } else {
      res.setHeader('Content-Disposition', `inline; filename="${document.filename}"`);
    }
    
    res.setHeader('Content-Length', document.size);

    // In production, you would stream from secure storage
    res.send(document.buffer);

  } catch (error) {
    console.error('View document error:', error);
    res.status(500).json({ 
      error: 'Failed to view document',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Update document metadata
router.put('/:id', authenticateToken, [
  body('title').optional().isLength({ min: 1, max: 200 }),
  body('description').optional().isLength({ max: 500 }),
  body('expirationDate').optional().isISO8601()
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const { title, description, expirationDate } = req.body;
    const document = documents.get(id);

    if (!document) {
      return res.status(404).json({ error: 'Document not found' });
    }

    if (document.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Update document metadata
    if (title) document.title = title;
    if (description !== undefined) document.description = description;
    if (expirationDate !== undefined) {
      document.expirationDate = expirationDate ? new Date(expirationDate).toISOString() : null;
    }
    document.updatedAt = new Date().toISOString();

    res.json({
      success: true,
      message: 'Document updated successfully',
      document: {
        id: document.id,
        title: document.title,
        type: document.type,
        description: document.description,
        expirationDate: document.expirationDate,
        updatedAt: document.updatedAt
      }
    });

  } catch (error) {
    console.error('Update document error:', error);
    res.status(500).json({ 
      error: 'Failed to update document',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Delete document
router.delete('/:id', authenticateToken, (req, res) => {
  try {
    const { id } = req.params;
    const document = documents.get(id);

    if (!document) {
      return res.status(404).json({ error: 'Document not found' });
    }

    if (document.userId !== req.user.userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // In production, you would also delete from secure storage
    documents.delete(id);

    res.json({
      success: true,
      message: 'Document deleted successfully'
    });

  } catch (error) {
    console.error('Delete document error:', error);
    res.status(500).json({ 
      error: 'Failed to delete document',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

// Get expiring documents summary
router.get('/expiring/summary', authenticateToken, (req, res) => {
  try {
    const userId = req.user.userId;
    const userDocuments = Array.from(documents.values())
      .filter(document => document.userId === userId);

    const now = new Date();
    const thirtyDaysFromNow = new Date();
    thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);

    const expiring = userDocuments.filter(document => 
      document.expirationDate && 
      new Date(document.expirationDate) <= thirtyDaysFromNow &&
      new Date(document.expirationDate) >= now
    );

    const expired = userDocuments.filter(document => 
      document.expirationDate && 
      new Date(document.expirationDate) < now
    );

    res.json({
      success: true,
      summary: {
        expiring: expiring.length,
        expired: expired.length,
        expiringDocuments: expiring.map(doc => ({
          id: doc.id,
          title: doc.title,
          type: doc.type,
          expirationDate: doc.expirationDate,
          daysUntilExpiration: Math.ceil((new Date(doc.expirationDate) - now) / (1000 * 60 * 60 * 24))
        })),
        expiredDocuments: expired.map(doc => ({
          id: doc.id,
          title: doc.title,
          type: doc.type,
          expirationDate: doc.expirationDate,
          daysOverdue: Math.ceil((now - new Date(doc.expirationDate)) / (1000 * 60 * 60 * 24))
        }))
      }
    });

  } catch (error) {
    console.error('Expiring documents summary error:', error);
    res.status(500).json({ 
      error: 'Failed to get expiring documents summary',
      details: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;