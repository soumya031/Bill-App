import jwt from 'jsonwebtoken';
import { config } from '../config.js';

export function signAccessToken(payload: Record<string, unknown>): string {
  return jwt.sign(payload, config.jwtSecret, { expiresIn: '7d' });
}

export function verifyAccessToken(token: string): Record<string, unknown> {
  return jwt.verify(token, config.jwtSecret) as Record<string, unknown>;
}
