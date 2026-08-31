/**
 * Bhashini Translation Service
 * 
 * Integration with Government of India's National Language Translation Mission (Bhashini)
 * API Access: https://apisetu.gov.in
 * Scale: 15+ million inferences daily, 36 Indian scripts, 22 scheduled languages
 * 
 * This service provides text translation for multi-lingual support.
 * When the Bhashini API is not configured, falls back to client-side i18n.
 */

const supportedLanguages = {
    'en': 'English',
    'hi': 'Hindi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'bn': 'Bengali',
    'mr': 'Marathi',
    'gu': 'Gujarati',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'pa': 'Punjabi',
    'or': 'Odia',
    'ur': 'Urdu',
    'as': 'Assamese',
    'mai': 'Maithili',
    'sat': 'Santali',
    'ks': 'Kashmiri',
    'ne': 'Nepali',
    'sd': 'Sindhi',
    'doi': 'Dogri',
    'mni': 'Manipuri',
    'brx': 'Bodo',
    'kS': 'Sanskrit'
};

class BhashiniService {
    constructor() {
        this.apiUrl = process.env.BHASHINI_API_URL || 'https://bhashini-api.gov.in/translate';
        this.apiKey = process.env.BHASHINI_API_KEY || '';
        this.enabled = !!this.apiKey;
    }

    /**
     * Translate text using Bhashini API
     * Falls back to returning original text if API is not configured
     */
    async translate(text, sourceLang = 'en', targetLang = 'hi') {
        if (!this.enabled) {
            console.warn('Bhashini API not configured — returning original text. Set BHASHINI_API_KEY in .env');
            return { translatedText: text, source: 'fallback', language: targetLang };
        }

        try {
            const response = await fetch(this.apiUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.apiKey}`
                },
                body: JSON.stringify({
                    input: [{ source: text }],
                    config: {
                        sourceLanguage: sourceLang,
                        targetLanguage: targetLang
                    }
                })
            });

            if (!response.ok) {
                throw new Error(`Bhashini API error: ${response.status}`);
            }

            const result = await response.json();
            return {
                translatedText: result.output?.[0]?.target || text,
                source: 'bhashini',
                language: targetLang
            };
        } catch (error) {
            console.error('Bhashini translation failed:', error.message);
            return { translatedText: text, source: 'error', language: targetLang, error: error.message };
        }
    }

    /**
     * Batch translate multiple texts
     */
    async translateBatch(texts, sourceLang = 'en', targetLang = 'hi') {
        const results = await Promise.all(
            texts.map(text => this.translate(text, sourceLang, targetLang))
        );
        return results.map(r => r.translatedText);
    }

    /**
     * Get list of supported languages
     */
    getSupportedLanguages() {
        return supportedLanguages;
    }

    /**
     * Check if Bhashini is configured and available
     */
    isAvailable() {
        return this.enabled;
    }
}

module.exports = new BhashiniService();
