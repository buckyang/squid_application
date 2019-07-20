const express = require('express');
const logger = require('./util/logger');
const exec = require('child_process').exec;
const fs = require('fs');

const app = express();

(async () => {


  // setup server
  app.get('/', async function (req, res) {
    res.end('Hello Wolrd');
  });


  app.get('/changeVps', async function(req, res){
    logger.info(`Requested ips ${req.ips}`)
    let confFile = './conf/squid.conf'
    let confFileDest = '/etc/squid/squid.conf'
    let squidConfStr = fs.readFileSync(confFile, 'utf-8')
    let ips = req.ip.match(/\d+\.\d+.\d+.\d+$/)
    let ip = ips ? ips[0]: ''
    squidConfStr = squidConfStr.replace('{{sourceServer}}', ip);
    fs.writeFileSync(confFileDest, squidConfStr)
    
    

    exec('systemctl restart squid',(error, stdout, stderr) => {
        logger.info(`Changed vps for remote ip ${ip}`)
        if(error){
            res.end(`Call error: JSON.stringify(Error)`)
        }else{
            res.end(`Call success: ${stdout}`)
        }
    })
  })
  app.listen(3000, function () {
      logger.info('Screenshot server listening on port 3000.');
  });
})();