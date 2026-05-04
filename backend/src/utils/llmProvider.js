function googleMapsUrl(destination) {
  if (!destination) return '';
  const lat = destination.latitude;
  const lon = destination.longitude;
  if (lat && lon) return `https://www.google.com/maps/search/?api=1&query=${lat},${lon}`;
  return `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(destination.name + ' Yogyakarta')}`;
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
    tags: destination.tags || [],
  };
}

function buildSystemPrompt() {
  return [
    'Kamu adalah "Mas/Mbak Guide Jogja", pemandu wisata Jawa di aplikasi JogjaSplorasi.',
    'Jawablah dalam bahasa Indonesia yang sopan, hangat, informatif, dan bernuansa Jawa secukupnya seperti "nggih", "monggo", atau "panjenengan" tanpa berlebihan.',
    'Gunakan hanya data destinasi dari konteks database JogjaSplorasi. Jangan mengarang destinasi, harga, jam buka, atau alamat baru.',
    'Kalau data tidak tersedia, sampaikan dengan jujur dan beri saran untuk verifikasi sumber resmi.',
    'Jika pengguna meminta rekomendasi, berikan alasan yang jelas, cocok untuk siapa, waktu terbaik, estimasi biaya dari data, dan link Google Maps bila ada.',
    'Format jawaban ringkas namun berguna, maksimal 5 poin utama kecuali pengguna meminta detail panjang.',
  ].join(' ');
}

function buildUserPrompt({ message, destinations, userName }) {
  const context = destinations.slice(0, Number(process.env.AI_GUIDE_MAX_CONTEXT_DESTINATIONS || 10)).map(compactDestination);
  return `Nama pengguna: ${userName || 'Pelancong'}\nPertanyaan: ${message}\nKonteks destinasi database JSON: ${JSON.stringify(context)}`;
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
      'HTTP-Referer': process.env.APP_PUBLIC_URL || 'http://localhost:3000',
      'X-Title': 'JogjaSplorasi',
    },
    body: JSON.stringify({
      model,
      temperature: 0.62,
      max_tokens: 850,
      messages: [
        { role: 'system', content: buildSystemPrompt() },
        { role: 'user', content: buildUserPrompt({ message, destinations, userName }) },
      ],
    }),
  });

  if (!response.ok) throw new Error(`OpenRouter error ${response.status}`);
  const data = await response.json();
  const answer = data?.choices?.[0]?.message?.content;
  if (!answer) return null;
  return answer.trim();
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
        temperature: 0.62,
        maxOutputTokens: 850,
      },
    }),
  });

  if (!response.ok) throw new Error(`Gemini error ${response.status}`);
  const data = await response.json();
  const answer = data?.candidates?.[0]?.content?.parts?.map((part) => part.text).filter(Boolean).join('\n');
  if (!answer) return null;
  return answer.trim();
}

async function buildLlmReply({ message, destinations, userName }) {
  const mode = (process.env.AI_GUIDE_MODE || 'local').toLowerCase();

  if (mode === 'gemini' || mode === 'google' || mode === 'google-gemini') {
    try {
      const answer = await callGemini({ message, destinations, userName });
      if (answer) return { answer, provider: 'gemini-database-grounded', confidence: 'high' };
    } catch (error) {
      console.warn('[AI] Gemini fallback:', error.message);
    }
  }

  if (mode === 'openrouter') {
    try {
      const answer = await callOpenRouter({ message, destinations, userName });
      if (answer) return { answer, provider: 'openrouter-database-grounded', confidence: 'high' };
    } catch (error) {
      console.warn('[AI] OpenRouter fallback:', error.message);
    }
  }

  return null;
}

module.exports = { buildLlmReply, googleMapsUrl, compactDestination };
