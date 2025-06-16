const multer = require('multer');
const path = require('path');

// Depolama konfigürasyonu
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/audio/');  // Ses dosyalarının kaydedileceği klasör
    },
    filename: (req, file, cb) => {
        // Benzersiz dosya adı oluşturma
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, uniqueSuffix + path.extname(file.originalname));
    }
});

// Dosya filtresi - sadece ses dosyalarını kabul et
const fileFilter = (req, file, cb) => {
    const allowedMimes = ['audio/mpeg', 'audio/wav', 'audio/ogg', 'audio/mp4'];
    if (allowedMimes.includes(file.mimetype)) {
        cb(null, true);
    } else {
        cb(new Error('Geçersiz dosya türü. Sadece ses dosyaları yüklenebilir.'), false);
    }
};

// Multer konfigürasyonu
const upload = multer({
    storage: storage,
    fileFilter: fileFilter,
    limits: {
        fileSize: 10 * 1024 * 1024, // 10MB limit
    }
});

module.exports = upload; 