const mongoose = require('mongoose');

const audioSchema = new mongoose.Schema({
    title: {
        type: String,
        required: true,
        trim: true
    },
    filepath: {
        type: String,
        required: true
    },
    uploadedBy: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
    },
}, {
    timestamps: true
});

// Indexes for better query performance
audioSchema.index({ uploadedBy: 1, createdAt: -1 });
audioSchema.index({ title: 'text', description: 'text' });

const Audio = mongoose.model('Audio', audioSchema);

module.exports = Audio; 