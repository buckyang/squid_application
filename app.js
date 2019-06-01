const puppeteer = require('puppeteer');
const express = require('express');
const logger = require('./util/logger');
const { Cluster } = require('puppeteer-cluster');

const app = express();

(async () => {
  const cluster = await Cluster.launch({
      concurrency: Cluster.CONCURRENCY_PAGE,
      maxConcurrency: 4,
      puppeteerOptions: {args: ['--no-sandbox', '--disable-setuid-sandbox']}
  });
  await cluster.task(async ({ page, data: query, worker }) => {
    let startTime = new Date().getTime();


    page.setViewport({
        width: (query.width? parseInt(query.width): 375),
        height: (query.height? parseInt(query.height): 667),
        deviceScaleFactor: (query.deviceScaleFactor ? parseFloat(query.deviceScaleFactor): 1.5)
    });    
    await page.goto(query.url);
    let screenshotResult = page.screenshot({fullPage: true, quality: (query.quality? parseInt(query.quality): 85), type: 'jpeg'});


    let endTime = new Date().getTime();
    logger.info(`worker: ${worker.id}, query: ${query.url? query.url: ''}, generate screenshot cost ${endTime - startTime} millisecond`)


    return screenshotResult;
  });

  // setup server
  app.get('/screenshot/:name', async function (req, res) {
      if (!req.query.url) {
          return res.end('Please specify url like this: ?url=example.com');
      }
      try {
          const screen = await cluster.execute(req.query);
          res.writeHead(200, {
              'Content-Type': 'image/jpg',
              'Content-Length': screen.length
          });
          res.end(screen);

      } catch (err) {
        logger.error(`query: ${JSON.stringify(req.query)}, error: ${err.message}`)
        res.end('Error: ' + err.message);
      }
  });

  app.listen(3000, function () {
      logger.info('Screenshot server listening on port 3000.');
  });
})();