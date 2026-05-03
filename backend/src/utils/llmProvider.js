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
    tags: destination.tags || [],
  };
}

async function callOpenRouter({ message, destinations, userName }) {
  const apiKey = process.env.OPENROUTER_API_KEY;
  if (!apiKey) return null;

  const model = process.env.OPENROUTER_MODEL || 'openai/gpt-4o-mini';
  const context = destinations.slice(0, 8).map(compactDestination);
  const system = [
    'Kamu adalah Pemandu Jogja AI di aplikasi JogjaSplorasi.',
    'Jawab dalam bahasa Indonesia yang hangat, fun, sopan, dan bernuansa tour guide Yogyakarta.',
    'Gunakan hanya destinasi dari konteks database. Jangan mengarang tempat baru.',
    'Jika memberi rekomendasi, sertakan alasan singkat dan link Google Maps dari data mapsUrl.',
    'Buat jawaban ramah semua umur dan mudah dipahami lansia.',
  ].join(' ');

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
      temperature: 0.65,
      max_tokens: 750,
      messages: [
        { role: 'system', content: system },
        { role: 'user', content: `Nama user: ${userName || 'Pelancong'}\nPertanyaan: ${message}\nKonteks destinasi JSON: ${JSON.stringify(context)}` },
      ],
    }),
  });

  if (!response.ok) throw new Error(`OpenRouter error ${response.status}`);
  const data = await response.json();
  const answer = data?.choices?.[0]?.message?.content;
  if (!answer) return null;
  return answer.trim();
}

async function buildLlmReply({ message, destinations, userName }) {
  const mode = (process.env.AI_GUIDE_MODE || 'local').toLowerCase();
  if (mode === 'openrouter') {
    try {
      const answer = await callOpenRouter({ message, destinations, userName });
      if (answer) return { answer, provider: 'openrouter', confidence: 'high' };
    } catch (error) {
      console.warn('[AI] OpenRouter fallback:', error.message);
    }
  }
  return null;
}

module.exports = { buildLlmReply, googleMapsUrl, compactDestination };
