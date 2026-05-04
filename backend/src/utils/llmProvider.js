const logger = require('./logger');

function googleMapsUrl(destination) {
  if (!destination) return '';
  const lat = destination.latitude;
  const lon = destination.longitude;
  if (lat && lon) return `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`;
  return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(`${destination.name} Yogyakarta`)}`;
}

function compactDestination(destination) {
  return {
    id: destination.id,
    name: destination.name,
    category: destination.category,
    type: destination.type,
    description: destination.description,
    story: destination.story,
    localInsight: destination.localInsight,
    address: destination.address,
    mapsUrl: googleMapsUrl(destination),
    bestTimeToVisit: destination.bestTimeToVisit,
    ticketPrice: destination.ticketPrice,
    openingHours: destination.openingHours,
    recommendedDuration: destination.recommendedDuration,
    culturalValue: destination.culturalValue,
    rating: destination.rating,
    tags: destination.tags || [],
  };
}

function buildSystemPrompt() {
  return [
    'Kamu adalah "Mas/Mbak Guide Jogja", pemandu wisata lokal di aplikasi JogjaSplorasi.',
    'Peranmu: membantu pengguna memilih destinasi Jogja dengan gaya ramah, sopan, halus, dan terasa seperti pemandu asli Yogyakarta.',
    'Bahasa utama WAJIB bahasa Indonesia yang mudah dipahami wisatawan luar daerah. Tambahkan nuansa Jawa ringan secukupnya, misalnya "Sugeng rawuh", "Nggih", "monggo", "matur nuwun", atau "panjenengan". Jangan menggunakan bahasa Jawa penuh.',
    'Awali jawaban dengan sapaan pendek bernuansa Jawa yang natural. Contoh: "Sugeng rawuh, Yudha. Nggih, ..." atau "Nggih, saya bantu pilihkan ...". Jangan terus-menerus memakai kalimat template "Siap, ...".',
    'Gunakan hanya data destinasi dari konteks database JogjaSplorasi. Jangan mengarang destinasi, alamat, harga, jam buka, rating, atau fasilitas yang tidak ada dalam konteks.',
    'Kalau data harga, jam buka, atau alamat belum tersedia/kurang pasti, sampaikan dengan jujur: "data ini sebaiknya dicek lagi di sumber resmi".',
    'Jawaban harus informatif: jelaskan kenapa destinasi cocok, suasananya seperti apa, cocok untuk siapa, waktu kunjungan yang disarankan, estimasi biaya/jam buka jika ada, dan arahkan ke Maps jika tersedia.',
    'Hindari repetisi deskripsi yang sama. Jangan menyalin satu kalimat database berulang-ulang.',
    'Jika pengguna bertanya malam hari, prioritaskan destinasi yang memang cocok malam/sore, pertunjukan, kuliner, atau area yang aman dikunjungi malam berdasarkan konteks.',
    'Jika pengguna meminta itinerary, susun rute singkat berurutan dengan alasan ringkas per titik.',
    'Format jawaban: paragraf pembuka singkat, lalu 1-4 rekomendasi berpoin. Tutup dengan kalimat sopan bernuansa Jogja. Maksimal 650 kata kecuali pengguna meminta detail panjang.',
  ].join('\n');
}

function buildUserPrompt({ message, destinations, userName }) {
  const contextLimit = Number(process.env.AI_GUIDE_MAX_CONTEXT_DESTINATIONS || 10);
  const context = destinations.slice(0, contextLimit).map(compactDestination);
  return [
    `Nama pengguna: ${userName || 'Pelancong'}`,
    `Pertanyaan pengguna: ${message}`,
    'Konteks destinasi database JogjaSplorasi dalam JSON:',
    JSON.stringify(context),
    'Tugas: jawab sebagai pemandu wisata Jogja yang sopan, informatif, dan bernuansa Jawa ringan. Tetap grounded pada JSON di atas.',
  ].join('\n');
}

function normalizeAnswer(answer, userName) {
  const clean = String(answer || '').trim();
  if (!clean) return null;

  const lower = clean.toLowerCase();
  const hasJavaneseTone = ['sugeng', 'nggih', 'monggo', 'matur nuwun', 'panjenengan'].some((word) => lower.includes(word));

  if (hasJavaneseTone) return clean;

  const greetingName = userName ? `, ${userName}` : '';
  return `Sugeng rawuh${greetingName}. Nggih, saya bantu sebagai pemandu Jogja.\n\n${clean}\n\nMatur nuwun, semoga perjalanan panjenengan di Jogja menyenangkan.`;
}

async function callOpenRouter({ message, destinations, userName }) {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) return null;

  const model = process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini';
  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
      'Content-Type': 'application/json',
      'HTTP-Referer': process.env.PUBLIC_BASE_URL || 'http://localhost:3000',
      'X-Title': 'JogjaSplorasi',
    },
    body: JSON.stringify({
      model,
      temperature: 0.55,
      max_tokens: 900,
      messages: [
        { role: 'system', content: buildSystemPrompt() },
        { role: 'user', content: buildUserPrompt({ message, destinations, userName }) },
      ],
    }),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    throw new Error(`OpenRouter error ${response.status}: ${body.slice(0, 220)}`);
  }

  const data = await response.json();
  const answer = data?.choices?.[0]?.message?.content;
  return normalizeAnswer(answer, userName);
}

async function callGemini({ message, destinations, userName }) {
  const apiKey = process.env.GEMINI_API_KEY || process.env.GOOGLE_GEMINI_API_KEY;
  if (!apiKey) return null;

  const model = process.env.GEMINI_MODEL || 'gemini-1.5-flash';
  const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(apiKey)}`;

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      systemInstruction: {
        parts: [{ text: buildSystemPrompt() }],
      },
      contents: [
        {
          role: 'user',
          parts: [{ text: buildUserPrompt({ message, destinations, userName }) }],
        },
      ],
      generationConfig: {
        temperature: 0.54,
        topP: 0.9,
        topK: 40,
        maxOutputTokens: 950,
      },
    }),
  });

  if (!response.ok) {
    const body = await response.text().catch(() => '');
    throw new Error(`Gemini error ${response.status}: ${body.slice(0, 220)}`);
  }

  const data = await response.json();
  const blocked = data?.promptFeedback?.blockReason;
  if (blocked) throw new Error(`Gemini blocked prompt: ${blocked}`);

  const answer = data?.candidates?.[0]?.content?.parts
    ?.map((part) => part.text)
    .filter(Boolean)
    .join('\n');

  return normalizeAnswer(answer, userName);
}

async function buildLlmReply({ message, destinations, userName }) {
  const mode = (process.env.AI_GUIDE_MODE || 'local').toLowerCase();
  const contextCount = destinations.length;

  logger.debug({ mode, contextCount }, '[AI] buildLlmReply invoked');

  if (mode === 'gemini' || mode === 'google' || mode === 'google-gemini') {
    try {
      const answer = await callGemini({ message, destinations, userName });
      if (answer) {
        logger.info({ provider: 'gemini', model: process.env.GEMINI_MODEL || 'gemini-1.5-flash', contextCount }, '[AI] Gemini response generated');
        return { answer, provider: 'gemini-database-grounded', confidence: 'high', fallbackReason: null };
      }
      logger.warn({ provider: 'gemini' }, '[AI] Gemini returned empty answer, using local fallback');
      return { answer: null, provider: null, confidence: null, fallbackReason: 'Gemini returned empty answer' };
    } catch (error) {
      logger.warn({ provider: 'gemini', err: error.message }, '[AI] Gemini failed, using local fallback');
      return { answer: null, provider: null, confidence: null, fallbackReason: error.message };
    }
  }

  if (mode === 'openrouter') {
    try {
      const answer = await callOpenRouter({ message, destinations, userName });
      if (answer) {
        logger.info({ provider: 'openrouter', model: process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini', contextCount }, '[AI] OpenRouter response generated');
        return { answer, provider: 'openrouter-database-grounded', confidence: 'high', fallbackReason: null };
      }
      logger.warn({ provider: 'openrouter' }, '[AI] OpenRouter returned empty answer, using local fallback');
      return { answer: null, provider: null, confidence: null, fallbackReason: 'OpenRouter returned empty answer' };
    } catch (error) {
      logger.warn({ provider: 'openrouter', err: error.message }, '[AI] OpenRouter failed, using local fallback');
      return { answer: null, provider: null, confidence: null, fallbackReason: error.message };
    }
  }

  logger.info({ mode }, '[AI] Local mode selected');
  return null;
}

module.exports = { buildLlmReply, googleMapsUrl, compactDestination, buildSystemPrompt };
