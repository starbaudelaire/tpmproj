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

function inferQueryContext(tokens) {
  const joined = tokens.join(' ');
  return {
    wantsNight: /malam|sore|sunset|senja/.test(joined),
    wantsCulinary: /kuliner|makan|murah|bakmi|gudeg|sate|kopi|warung/.test(joined),
    wantsCulture: /budaya|sejarah|candi|museum|seni|ramayana|pertunjukan/.test(joined),
    wantsNature: /alam|pantai|bukit|hutan|view|foto|sunrise/.test(joined),
  };
}

function scoreDestination(destination, queryTokens, context = {}) {
  const haystack = destinationText(destination).toLowerCase();
  const category = String(destination.category || '').toLowerCase();
  const name = String(destination.name || '').toLowerCase();
  const tags = (destination.tags || []).map((tag) => String(tag).toLowerCase());

  let score = 0;
  for (const token of queryTokens) {
    if (haystack.includes(token)) score += 8;
    if (name.includes(token)) score += 12;
    if (tags.some((tag) => tag.includes(token))) score += 8;
    if (category.includes(token)) score += 10;
  }

  if (context.wantsNight && /malam|sore|senja|ramayana|kuliner|warung|kopi|alun|malioboro/.test(haystack)) score += 22;
  if (context.wantsCulinary && /kuliner|makan|bakmi|gudeg|sate|kopi|warung|resto|angkringan|masakan/.test(haystack)) score += 22;
  if (context.wantsCulture && /budaya|sejarah|candi|museum|seni|ramayana|keraton/.test(haystack)) score += 18;
  if (context.wantsNature && /alam|pantai|bukit|hutan|view|foto|sunrise|sunset/.test(haystack)) score += 18;
  if (destination.isFeatured) score += 7;
  score += Number(destination.rating || 0) * 2;
  score += Number(destination.culturalValue || 0) * 0.8;
  return score;
}

function pickRelevantDestinations(destinations, userMessage, options = {}) {
  const queryTokens = tokenize(userMessage);
  const inferred = inferQueryContext(queryTokens);

  return destinations
    .map((destination) => ({
      destination,
      score: scoreDestination(destination, queryTokens, { ...options, ...inferred }),
    }))
    .filter((item) => item.score > 0)
    .sort((a, b) => b.score - a.score)
    .slice(0, options.limit || 6)
    .map((item) => item.destination);
}

function cleanCategory(destination) {
  const text = [destination.category, ...(destination.tags || []), destination.name].filter(Boolean).join(' ').toLowerCase();
  if (/bakmi|sate|gudeg|warung|kuliner|makan|kopi|angkringan|resto|masakan/.test(text)) return 'Kuliner';
  if (/candi|sejarah|heritage/.test(text)) return 'Sejarah';
  if (/museum|seni|galeri|ramayana|budaya|keraton/.test(text)) return 'Budaya';
  if (/pantai|bukit|alam|hutan|viewpoint|foto/.test(text)) return 'Alam';
  return destination.category ? `${destination.category.charAt(0).toUpperCase()}${destination.category.slice(1)}` : 'Wisata';
}

function formatDestination(destination, index) {
  const category = cleanCategory(destination);
  const maps = googleMapsUrl(destination);
  const description = destination.localInsight || destination.description || destination.story || 'Destinasi ini tersedia di database JogjaSplorasi.';
  const details = [];
  if (destination.openingHours) details.push(`Jam: ${destination.openingHours}`);
  if (destination.ticketPrice) details.push(`Tiket: ${destination.ticketPrice}`);
  if (destination.bestTimeToVisit) details.push(`Waktu cocok: ${destination.bestTimeToVisit}`);

  return [
    `${index}. ${destination.name} (${category})`,
    `   ${description}`,
    details.length ? `   ${details.join(' • ')}` : '   Detail jam/harga sebaiknya dicek kembali di sumber resmi.',
    `   Maps: ${maps}`,
  ].join('\n');
}

function buildLocalGuideReply({ message, destinations, userName }) {
  const relevant = pickRelevantDestinations(destinations, message, { limit: 4 });
  const greeting = `Sugeng rawuh${userName ? `, ${userName}` : ''}. Nggih, saya bantu pilihkan dari database JogjaSplorasi.`;

  if (!relevant.length) {
    const featured = destinations
      .slice()
      .sort((a, b) => Number(b.rating || 0) - Number(a.rating || 0))
      .slice(0, 3);
    return {
      answer: [
        greeting,
        '',
        'Saya belum menemukan destinasi yang sangat pas dari pertanyaan panjenengan. Monggo, sebagai alternatif ini pilihan populer yang bisa dipertimbangkan:',
        '',
        ...featured.map((item, index) => formatDestination(item, index + 1)),
        '',
        'Matur nuwun. Panjenengan bisa memperjelas minat seperti kuliner, budaya, alam, dekat Malioboro, murah, atau cocok malam hari.',
      ].join('\n'),
      citedDestinationIds: featured.map((item) => item.id),
      confidence: 'low',
    };
  }

  return {
    answer: [
      greeting,
      '',
      'Rekomendasi yang cocok untuk panjenengan:',
      '',
      ...relevant.map((item, index) => formatDestination(item, index + 1)),
      '',
      'Tips pemandu: sebelum berangkat, monggo cek kembali jam operasional dan rute Maps agar perjalanan lebih nyaman. Matur nuwun.',
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
      category: cleanCategory(destination),
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
