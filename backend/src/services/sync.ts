import { store } from '../store.js';

export function enqueueSync(input: {
  businessId: string;
  entity: string;
  entityId: string;
  op: 'upsert' | 'delete';
  payload: string;
}) {
  return store.enqueueSync({
    businessId: input.businessId,
    entity: input.entity,
    entityId: input.entityId,
    op: input.op,
    payload: input.payload,
  });
}
