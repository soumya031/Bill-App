import 'dotenv/config';
export const config = {
    port: Number(process.env.PORT ?? 4000),
    jwtSecret: process.env.JWT_SECRET ?? 'dev-secret-change-me',
    nodeEnv: process.env.NODE_ENV ?? 'development',
};
