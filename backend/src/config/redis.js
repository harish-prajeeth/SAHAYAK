const { createClient } = require('redis');

let redis = null;
let redisAvailable = false;

async function connectRedis() {
    try {
        redis = createClient({
            url: process.env.REDIS_URL || 'redis://localhost:6379',
            socket: { connectTimeout: 3000, reconnectStrategy: (retries) => Math.min(retries * 100, 3000) }
        });
        redis.on('error', (err) => { redisAvailable = false; });
        redis.on('connect', () => { redisAvailable = true; });
        await redis.connect();
        console.log('Redis connected');
    } catch (error) {
        console.warn('Redis unavailable, running without cache:', error.message);
        redisAvailable = false;
    }
}

function getRedis() { return redis; }
function isRedisAvailable() { return redisAvailable && redis?.isReady; }

// Graceful cache operations
async function cacheGet(key) {
    if (!isRedisAvailable()) return null;
    try { const data = await redis.get(key); return data ? JSON.parse(data) : null; } catch { return null; }
}

async function cacheSet(key, value, ttlSeconds = 3600) {
    if (!isRedisAvailable()) return;
    try { await redis.set(key, JSON.stringify(value), { EX: ttlSeconds }); } catch {}
}

async function cacheDel(key) {
    if (!isRedisAvailable()) return;
    try { await redis.del(key); } catch {}
}

module.exports = { connectRedis, getRedis, isRedisAvailable, cacheGet, cacheSet, cacheDel };
