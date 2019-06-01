const winston = require('winston');

const logger = winston.createLogger({
    level: 'info',
    format: winston.format.combine(
      winston.format.timestamp({format: 'YYYY-MM-DD HH:mm:ss'}),
      winston.format.json()
    ),
    defaultMeta: { service: 'user-service' },
    transports: [
      new winston.transports.File({ filename: '/opt/logs/puppeteer_application/app_access.log' })
    ]
  });
  if (process.env.NODE_ENV !== 'production') {
    logger.add(new winston.transports.Console({
      format: winston.format.combine(
        winston.format.timestamp({format: 'YYYY-MM-DD HH:mm:ss'}),
        winston.format.simple()
      ),
    }));
  }

module.exports = logger;