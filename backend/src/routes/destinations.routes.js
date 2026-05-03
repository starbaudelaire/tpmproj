const express = require('express');
const { z } = require('zod');
const slugify = require('slugify');
const prisma = require('../config/prisma');
const asyncHandler = require('../utils/asyncHandler');
const { auth, requireAdmin } = require('../middleware/auth');
const AppError = require('../utils/AppError');
const router = express.Router();

const destinationSelect = {
  id: true,
  slug: true,
  name: true,
  type: true,
  category: true,
  description: true,
  story: true,
  localInsight: true,
  address: true,
  latitude: true,
  longitude: true,
  imageUrl: true,
  rating: true,
  ticketPrice: true,
  openingHours: true,
  bestTimeToVisit: true,
  recommendedDuration: true,
  culturalValue: true,
  isFeatured: true,
  isVerified: true,
  tags: true,
  createdAt: true,
  updatedAt: true,
};

function normalizeType(type) {
  if (!type) return undefined;
  return String(type).toUpperCase();
}

async function uniqueSlug(name, ignoredId) {
  const base = slugify(name, { lower: true, strict: true }) || `destinasi-${Date.now()}`;
  let slug = base;
  let count = 2;
  while (true) {
    const exists = await prisma.destination.findUnique({ where: { slug } });
    if (!exists || exists.id === ignoredId) return slug;
    slug = `${base}-${count++}`;
  }
}

router.get('/', asyncHandler(async (req, res) => {
  const { search, type, category, tag, featured } = req.query;
  const where = { isActive: true };
  const normalizedType = normalizeType(type);
  if (normalizedType) where.type = normalizedType;
  if (category) where.category = { contains: String(category), mode: 'insensitive' };
  if (tag) where.tags = { has: String(tag) };
  if (featured === 'true') where.isFeatured = true;
  if (search) {
    const value = String(search);
    where.OR = [
      { name: { contains: value, mode: 'insensitive' } },
      { description: { contains: value, mode: 'insensitive' } },
      { category: { contains: value, mode: 'insensitive' } },
      { tags: { has: value } },
    ];
  }
  const data = await prisma.destination.findMany({
    where,
    select: destinationSelect,
    orderBy: [{ isFeatured: 'desc' }, { rating: 'desc' }, { name: 'asc' }],
  });
  res.json(data);
}));

router.get('/featured', asyncHandler(async (req, res) => {
  const data = await prisma.destination.findMany({
    where: { isActive: true, isFeatured: true },
    select: destinationSelect,
    orderBy: { rating: 'desc' },
  });
  res.json(data);
}));

router.get('/:idOrSlug', asyncHandler(async (req, res) => {
  const idOrSlug = req.params.idOrSlug;
  const item = await prisma.destination.findFirst({
    where: {
      isActive: true,
      OR: [{ id: idOrSlug }, { slug: idOrSlug }],
    },
    select: destinationSelect,
  });
  if (!item) throw new AppError('Destinasi tidak ditemukan.', 404, 'DESTINATION_NOT_FOUND');
  res.json(item);
}));

const destinationSchema = z.object({
  name: z.string().min(2),
  type: z.enum(['TOURISM', 'CULINARY', 'CULTURE']),
  category: z.string().min(2),
  description: z.string().min(3),
  story: z.string().optional().nullable(),
  localInsight: z.string().optional().nullable(),
  address: z.string().min(3),
  latitude: z.number(),
  longitude: z.number(),
  imageUrl: z.string().url().optional().nullable(),
  rating: z.number().min(0).max(5).optional(),
  ticketPrice: z.string().optional().nullable(),
  openingHours: z.string().optional().nullable(),
  bestTimeToVisit: z.string().optional().nullable(),
  recommendedDuration: z.string().optional().nullable(),
  culturalValue: z.number().int().min(0).max(5).optional(),
  isFeatured: z.boolean().optional(),
  tags: z.array(z.string()).optional(),
});

router.post('/', auth, requireAdmin, asyncHandler(async (req, res) => {
  const body = destinationSchema.parse(req.body);
  const item = await prisma.destination.create({
    data: { ...body, slug: await uniqueSlug(body.name) },
    select: destinationSelect,
  });
  res.status(201).json(item);
}));

router.patch('/:id', auth, requireAdmin, asyncHandler(async (req, res) => {
  const body = destinationSchema.partial().parse(req.body);
  const data = { ...body };
  if (body.name) data.slug = await uniqueSlug(body.name, req.params.id);
  const item = await prisma.destination.update({
    where: { id: req.params.id },
    data,
    select: destinationSelect,
  });
  res.json(item);
}));

router.delete('/:id', auth, requireAdmin, asyncHandler(async (req, res) => {
  await prisma.destination.update({ where: { id: req.params.id }, data: { isActive: false } });
  res.json({ success: true, message: 'Destinasi berhasil dinonaktifkan.' });
}));

module.exports = router;
