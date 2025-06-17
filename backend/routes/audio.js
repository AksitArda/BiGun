const router = require('express').Router();
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');
const Audio = require('../models/Audio');

// Ses dosyası yükleme
router.post('/upload', auth, upload.single('audio'), async (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: 'Lütfen bir ses dosyası yükleyin.' });
        }

        const audio = new Audio({
            title: req.body.title || 'Untitled Audio',
            filepath: req.file.path,
            uploadedBy: req.user.id,
            duration: parseInt(req.body.duration) || 0,
            waveformData: JSON.parse(req.body.waveformData || '[]'),
            isPublic: req.body.isPublic !== 'false'
        });

        await audio.save();
        
        const populatedAudio = await Audio.findById(audio._id)
            .populate('uploadedBy', 'username')
            .populate('comments.user', 'username');

        res.status(201).json(populatedAudio);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Feed - Arkadaşların ses dosyalarını getir
router.get('/feed', auth, async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 0;
        const limit = parseInt(req.query.limit) || 20;
        
        const audios = await Audio.find({ 
            isPublic: true,
            filepath: { $exists: true, $ne: null } // Ensure filepath exists and is not null
        })
            .sort({ createdAt: -1 })
            .skip(page * limit)
            .limit(limit)
            .populate('uploadedBy', 'username')
            .populate('comments.user', 'username')
            .populate('likes', 'username');
        
        // Filter out any entries that might have invalid filepath
        const validAudios = audios.filter(audio => audio.filepath && audio.filepath.trim() !== '');
        
        const total = await Audio.countDocuments({ 
            isPublic: true,
            filepath: { $exists: true, $ne: null }
        });
        
        res.json({
            audios: validAudios,
            hasMore: (page + 1) * limit < total
        });
    } catch (error) {
        console.error('Feed error:', error);
        res.status(500).json({ message: error.message });
    }
});

// Belirli bir ses dosyasını getir
router.get('/:id', auth, async (req, res) => {
    try {
        const audio = await Audio.findById(req.params.id)
            .populate('uploadedBy', 'username')
            .populate('comments.user', 'username')
            .populate('likes', 'username');
        
        if (!audio) {
            return res.status(404).json({ message: 'Ses dosyası bulunamadı.' });
        }

        if (!audio.isPublic && audio.uploadedBy._id.toString() !== req.user.id) {
            return res.status(403).json({ message: 'Bu ses dosyasına erişim izniniz yok.' });
        }

        res.json(audio);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Ses dosyasını sil
router.delete('/:id', auth, async (req, res) => {
    try {
        const audio = await Audio.findOne({
            _id: req.params.id,
            uploadedBy: req.user.id
        });

        if (!audio) {
            return res.status(404).json({ message: 'Ses dosyası bulunamadı.' });
        }

        await audio.remove();
        res.json({ message: 'Ses dosyası başarıyla silindi.' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Yorum ekle
router.post('/:id/comments', auth, async (req, res) => {
    try {
        const audio = await Audio.findById(req.params.id);
        
        if (!audio) {
            return res.status(404).json({ message: 'Ses dosyası bulunamadı.' });
        }

        if (!audio.isPublic && audio.uploadedBy.toString() !== req.user.id) {
            return res.status(403).json({ message: 'Bu ses dosyasına yorum yapamazsınız.' });
        }

        const comment = {
            user: req.user.id,
            text: req.body.text
        };

        audio.comments.push(comment);
        await audio.save();

        const populatedAudio = await Audio.findById(audio._id)
            .populate('uploadedBy', 'username')
            .populate('comments.user', 'username')
            .populate('likes', 'username');

        res.status(201).json(populatedAudio);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Yorum sil
router.delete('/:audioId/comments/:commentId', auth, async (req, res) => {
    try {
        const audio = await Audio.findById(req.params.audioId);
        
        if (!audio) {
            return res.status(404).json({ message: 'Ses dosyası bulunamadı.' });
        }

        const comment = audio.comments.id(req.params.commentId);
        
        if (!comment) {
            return res.status(404).json({ message: 'Yorum bulunamadı.' });
        }

        if (comment.user.toString() !== req.user.id && audio.uploadedBy.toString() !== req.user.id) {
            return res.status(403).json({ message: 'Bu yorumu silme yetkiniz yok.' });
        }

        comment.remove();
        await audio.save();

        const populatedAudio = await Audio.findById(audio._id)
            .populate('uploadedBy', 'username')
            .populate('comments.user', 'username')
            .populate('likes', 'username');

        res.json(populatedAudio);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Beğeni ekle/kaldır
router.post('/:id/like', auth, async (req, res) => {
    try {
        const audio = await Audio.findById(req.params.id);
        
        if (!audio) {
            return res.status(404).json({ message: 'Ses dosyası bulunamadı.' });
        }

        if (!audio.isPublic && audio.uploadedBy.toString() !== req.user.id) {
            return res.status(403).json({ message: 'Bu ses dosyasını beğenemezsiniz.' });
        }

        const likeIndex = audio.likes.indexOf(req.user.id);
        
        if (likeIndex === -1) {
            audio.likes.push(req.user.id);
        } else {
            audio.likes.splice(likeIndex, 1);
        }

        await audio.save();

        const populatedAudio = await Audio.findById(audio._id)
            .populate('uploadedBy', 'username')
            .populate('comments.user', 'username')
            .populate('likes', 'username');

        res.json(populatedAudio);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Kullanıcının ses dosyalarını getir
router.get('/user/:userId', auth, async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 0;
        const limit = parseInt(req.query.limit) || 20;
        
        const query = { uploadedBy: req.params.userId };
        if (req.params.userId !== req.user.id) {
            query.isPublic = true;
        }

        const audios = await Audio.find(query)
            .sort({ createdAt: -1 })
            .skip(page * limit)
            .limit(limit)
            .populate('uploadedBy', 'username')
            .populate('comments.user', 'username')
            .populate('likes', 'username');
        
        const total = await Audio.countDocuments(query);
        
        res.json({
            audios,
            hasMore: (page + 1) * limit < total
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router; 