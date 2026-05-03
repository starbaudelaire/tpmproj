const { googleMapsUrl } = require('./llmProvider');
function tokenize(text) {
  return String(text || '')
    .toLowerCase()
    .replace(/[^a-z0-9\u00c0-\u024f\u1e00-\u1eff\s-]/g, ' ')
    .split(/\s+/)
    .filter(Boolean);
}

function destinationText(destination) {
  return [
    destination.name,
    destination.type,
    destination.category,
    destination.description,
    destination.story,
    destination.localInsight,
    destination.address,
    destination.bestTimeToVisit,
    destination.recommendedDuration,
    destination.ticketPrice,
    ...(destination.tags || []),
  ].filter(Boolean).join(' ');
}

function scoreDestination(destination, queryTokens, context = {}) {
  const haystack = destinationText(destination).toLowerCase();
  let score = 0;
  for (const token of queryTokens) {
    if (haystack.includes(token)) score += 8;
    if ((destination.name || '').toLowerCase().includes(token)) score += 10;
    if ((destination.tags || []).some((tag) => tag.toLowerCase().includes(token))) score += 8;
  }
  if (context.type && destination.type === context.type) score += 20;
  if (context.preferredCategories?.includes(destination.type?.toLowerCase())) score += 6;
  if (destination.isFeatured) score += 7;
  score += Number(destination.rating || 0) * 2;
  score += Number(destination.culturalValue || 0) * 0.8;
  return score;
}

function pickRelevantDestinations(destinations, userMessage, options = {}) {
  const queryTokens = tokenize(userMessage);
  return destinations
    .map((destination) => ({
      destination,
      score: scoreDestination(destination, queryTokens, options),
    }))
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, options.limit || 6)
    .map((item) => item.destination);
}

function formatDestination(destination) {
  const tags = (destination.tags || []).slice(0, 4).join(', ');
  const maps = googleMapsUrl(destination);
  return `${destination.name} (${destination.category}) - ${destination.description}${destination.localInsight ? ` Insight lokal: ${destination.localInsight}` : ''}${destination.ticketPrice ? ` Tiket: ${destination.ticketPrice}.` : ''}${destination.openingHours ? ` Jam buka: ${destination.openingHours}.` : ''}${tags ? ` Tag: ${tags}.` : ''} Maps: ${maps}`;
}

function buildLocalGuideReply({ message, destinations, userName }) {
  const relevant = pickRelevantDestinations(destinations, message, { limit: 5 });
  if (!relevant.length) {
    const featured = destinations
      .slice()
      .sort((a, b) => Number(b.rating || 0) - Number(a.rating || 0))
      .slice(0, 3);
    return {
      answer: [
        `Saya belum menemukan destinasi yang sangat cocok dari pertanyaan itu${userName ? `, ${userName}` : ''}.`,
        'Sebagai alternatif, ini pilihan populer yang aman untuk kamu pertimbangkan:',
        ...featured.map((item, index) => `${index + 1}. ${formatDestination(item)}`),
        'Anda bisa memperjelas minat seperti budaya, kuliner, alam, dekat Malioboro, murah, atau cocok sore hari.',
      ].join('\n'),
      citedDestinationIds: featured.map((item) => item.id),
      confidence: 'low',
    };
  }

  return {
    answer: [
      `Siap${userName ? `, ${userName}` : ''}! Ini rekomendasi Jogja yang cocok dari database JogjaSplorasi:`,
      ...relevant.map((item, index) => `${index + 1}. ${formatDestination(item)}`),
      'Tips pemandu: cek kembali jam operasional sebelum berangkat, lalu buka link Maps untuk rute paling nyaman.',
    ].join('\n'),
    citedDestinationIds: relevant.map((item) => item.id),
    confidence: 'medium',
  };
}

function buildItinerary({ destinations, days = 1, pace = 'normal' }) {
  const perDay = pace === 'slow' ? 3 : pace === 'fast' ? 5 : 4;
  const sorted = destinations
    .slice()
    .sort((a, b) => {
      const rb = Number(b.rating || 0) + Number(b.culturalValue || 0) / 10 + (b.isFeatured ? 1 : 0);
      const ra = Number(a.rating || 0) + Number(a.culturalValue || 0) / 10 + (a.isFeatured ? 1 : 0);
      return rb - ra;
    })
    .slice(0, days * perDay);

  const plan = [];
  for (let day = 1; day <= days; day += 1) {
    const stops = sorted.slice((day - 1) * perDay, day * perDay).map((destination, index) => ({
      order: index + 1,
      destinationId: destination.id,
      name: destination.name,
      type: destination.type,
      category: destination.category,
      address: destination.address,
      reason: destination.localInsight || destination.description,
    }));
    plan.push({ day, stops });
  }
  return plan;
}

module.exports = {
  buildLocalGuideReply,
  buildItinerary,
  pickRelevantDestinations,
};
