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
            uploadedBy: req.user.id
        });

        await audio.save();
        res.status(201).json(audio);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Feed - Arkadaşların ses dosyalarını getir
router.get('/feed', auth, async (req, res) => {
    try {
        // TODO: Arkadaş listesi implementasyonuna göre sorgu güncellenecek
        const audios = await Audio.find()
            .sort({ createdAt: -1 })
            .populate('uploadedBy', 'username')
            .limit(20);
        
        res.json(audios);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

// Belirli bir ses dosyasını getir
router.get('/:id', auth, async (req, res) => {
    try {
        const audio = await Audio.findById(req.params.id)
            .populate('uploadedBy', 'username');
        
        if (!audio) {
            return res.status(404).json({ message: 'Ses dosyası bulunamadı.' });
        }

        res.json(audio);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router; 