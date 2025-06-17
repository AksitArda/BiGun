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
    duration: {
        type: Number, // milisaniye cinsinden
        required: true
    },
    waveformData: {
        type: [Number],
        required: true,
        validate: {
            validator: function(arr) {
                return arr.every(val => val >= 0 && val <= 1);
            },
            message: 'Waveform değerleri 0-1 arasında olmalıdır'
        }
    },
    comments: [{
        user: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            required: true
        },
        text: {
            type: String,
            required: true,
            trim: true
        },
        createdAt: {
            type: Date,
            default: Date.now
        }
    }],
    likes: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
    }],
    isPublic: {
        type: Boolean,
        default: true
    }
}, {
    timestamps: true,
    toJSON: {
        virtuals: true,
        transform: function(doc, ret) {
            ret.id = ret._id;
            delete ret._id;
            delete ret.__v;
            return ret;
        }
    }
});

// Indexes for better query performance
audioSchema.index({ uploadedBy: 1, createdAt: -1 });
audioSchema.index({ title: 'text' });
audioSchema.index({ isPublic: 1 });
audioSchema.index({ 'comments.createdAt': -1 });

const Audio = mongoose.model('Audio', audioSchema);

module.exports = Audio; 