import { store } from '../store.js';
export function enqueueSync(input) {
    return store.enqueueSync({
        businessId: input.businessId,
        entity: input.entity,
        entityId: input.entityId,
        op: input.op,
        payload: input.payload,
    });
}
