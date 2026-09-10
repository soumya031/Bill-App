import jwt from 'jsonwebtoken';
import { config } from '../config.js';
export function signAccessToken(payload) {
    return jwt.sign(payload, config.jwtSecret, { expiresIn: '7d' });
}
export function verifyAccessToken(token) {
    return jwt.verify(token, config.jwtSecret);
}
