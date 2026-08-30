/**
 * Global error handling middleware
 */
function errorHandler(err, req, res, next) {
    console.error('Unhandled error:', err);

    if (err.name === 'ValidationError') {
        return res.status(400).json({ success: false, error: err.message });
    }
    if (err.name === 'UnauthorizedError') {
        return res.status(401).json({ success: false, error: 'Unauthorized' });
    }

    res.status(500).json({ success: false, error: 'Internal server error' });
}

module.exports = errorHandler;
