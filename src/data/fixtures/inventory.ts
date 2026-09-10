import type { InventoryBalance } from '@/domain';
import { CONSUMER_USER_ID } from './users';
import { daysAgo, q } from './_helpers';

export const inventoryBalances: InventoryBalance[] = [
  {
    id: 'inv-001',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-001', packageId: 'pkg-001' },
    mineralId: 'min-grit',
    receivedQuantity: q(140),
    consumedQuantity: q(28),
    transferredQuantity: q(15), // 15 MT transferred to Package B
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(1, '16:20:00'),
  },
  {
    id: 'inv-002',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-001', packageId: 'pkg-001' },
    mineralId: 'min-sand',
    receivedQuantity: q(120),
    consumedQuantity: q(15),
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(3, '15:05:00'),
  },
  {
    id: 'inv-003',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-002', packageId: 'pkg-003' },
    mineralId: 'min-murum',
    receivedQuantity: q(260),
    consumedQuantity: q(40),
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(2, '12:40:00'),
  },
  {
    id: 'inv-004',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-001', packageId: 'pkg-002' },
    mineralId: 'min-trap',
    receivedQuantity: q(180),
    consumedQuantity: q(35),
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(2, '17:15:00'),
  },
  {
    id: 'inv-004b',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-001', packageId: 'pkg-002' },
    mineralId: 'min-sand',
    receivedQuantity: q(95),
    consumedQuantity: q(10),
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(1, '14:10:00'),
  },
  {
    id: 'inv-005',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-002', packageId: 'pkg-004' },
    mineralId: 'min-grit',
    receivedQuantity: q(340),
    consumedQuantity: q(60),
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(4, '11:30:00'),
  },
  {
    id: 'inv-007',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-003', packageId: 'pkg-005' },
    mineralId: 'min-sand',
    receivedQuantity: q(160),
    consumedQuantity: q(30),
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(1, '11:20:00'),
  },
  {
    id: 'inv-008',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-003', packageId: 'pkg-005' },
    mineralId: 'min-grit',
    receivedQuantity: q(220),
    consumedQuantity: q(45),
    transferredQuantity: q(20),
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(2, '16:45:00'),
  },
  {
    id: 'inv-009',
    scope: { kind: 'PACKAGE', organizationId: 'org-001', projectId: 'proj-003', packageId: 'pkg-005' },
    mineralId: 'min-murum',
    receivedQuantity: q(310),
    consumedQuantity: q(60),
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(3, '09:30:00'),
  },

  /* --- Normal Consumer: flat scope, no package. --- */
  {
    id: 'inv-006',
    scope: { kind: 'CONSUMER', userId: CONSUMER_USER_ID },
    mineralId: 'min-sand',
    receivedQuantity: q(24),
    consumedQuantity: q(0),
    transferredQuantity: q(3), // 3 Brass returned to stockpoint
    status: 'ACTIVE_ON_SITE',
    lastUpdatedAt: daysAgo(5, '10:10:00'),
  },
];
