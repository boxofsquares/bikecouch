/**
 * Responds to any HTTP request.
 *
 * @param {!Object} req HTTP request context.
 * @param {!Object} res HTTP response context.
 */

const vision = require('@google-cloud/vision').v1p3beta1;
const sharp = require('sharp');

const client = new vision.ImageAnnotatorClient();


exports.helloWorld = (req, res) => {
  let b64image = req.body.image;
  let left = req.body.left;
  let right = req.body.right;
  let anchors = JSON.parse(req.body.anchors);
  let imgBuffer = Buffer.from(b64image, 'base64');

  let leftFocus = anchors['left'];
  let rightFocus = anchors['right'];
  console.log(JSON.stringify(leftFocus));
  console.log(JSON.stringify(rightFocus));

  const image = sharp(imgBuffer)
  image.metadata()
    .then(metadata => {
      var promises = [];

      console.log(`width: ${metadata.width}`);
      console.log(`height: ${metadata.height}`);
      if (metadata.width > metadata.height) {
        let ldx = Math.floor(leftFocus['dy_offset'] * metadata.width) - 1;
        let ldy = Math.floor((1 - leftFocus['dx_offset'] - leftFocus['width']) * metadata.height) - 1;
        let lw =  Math.floor(Math.min(leftFocus['height'] * metadata.width - 1, metadata.width - ldx - 1));
        let lh = Math.floor(Math.min(leftFocus['width'] * metadata.height - 1, metadata.height - ldy - 1));
        promises.push(
          image
            .clone()
            // .extract({ left: 0, top: 0, width: Math.floor(metadata.width / 2), height: metadata.height - 1 })
            .extract({
              left: ldx,
              top: ldy,
              width: lw,
              height: lh,
            })
            .resize(640, 480)
            .min()
            .toBuffer()
            .then(outputBuffer => {
              return outputBuffer.toString('base64');
            })
        );
        let rdx = Math.floor(rightFocus['dy_offset'] * metadata.width) - 1;
        let rdy = Math.floor((1 - rightFocus['dx_offset'] - rightFocus['width']) * metadata.height) - 1;
        let rw =  Math.floor(Math.min(rightFocus['height'] * metadata.width - 1, metadata.width - rdx - 1));
        let rh = Math.floor(Math.min(rightFocus['width'] * metadata.height - 1, metadata.height - rdy - 1));
        promises.push(
          image
            // .extract({ left: Math.floor(metadata.width / 2), top: 0, width: Math.floor(metadata.width / 2) - 10, height: metadata.height - 1 })
            .extract({
              left: rdx,
              top: rdy,
              width: rw,
              height: rh,
            })
            .resize(640, 480)
            .min()
            .toBuffer()
            .then(outputBuffer => {
              return outputBuffer.toString('base64');
            })
        );
      } else {
        let ldx = Math.floor(leftFocus['dx_offset'] * metadata.width) - 1;
        let ldy = Math.floor(leftFocus['dy_offset'] * metadata.height) - 1;
        let lw =  Math.floor(Math.min(leftFocus['width'] * metadata.width - 1, metadata.width - ldx - 1));
        let lh = Math.floor(Math.min(leftFocus['height'] * metadata.height - 1, metadata.height - ldy - 1));
        console.log(`dx: ${ldx} | dy: ${ldy} | w: ${lw} | h: ${lh}`);
        promises.push(
          image
            .clone()
            .extract({ 
              left: ldx,
              top: ldy, 
              width: lw,
              height: lh,
            })
            // .extract({ left: 0, top: 0, width: metadata.width - 1, height: Math.round(metadata.height / 2) })
            .resize(640, 480)
            .min()
            .toBuffer()
            .then(outputBuffer => {
              return outputBuffer.toString('base64');
            })
        );
        let rdx = Math.floor(rightFocus['dx_offset'] * metadata.width) - 1;
        let rdy = Math.floor(rightFocus['dy_offset'] * metadata.height) - 1;
        let rw =  Math.floor(Math.min(rightFocus['width'] * metadata.width - 1, metadata.width - rdx - 1));
        let rh = Math.floor(Math.min(rightFocus['height'] * metadata.height - 1, metadata.height - rdy - 1));
        console.log(`dx: ${rdx} | dy: ${rdy} | w: ${rw} | h: ${rh}`);
        promises.push(
          image
            .extract({ 
              left: rdx,
              top: rdy, 
              width: rw, 
              height: rh, 
            })
              // .extract({ 
              //   left: 0,
              //   top: Math.round(metadata.height / 2), 
              //   width: metadata.width - 1, 
              //   height: Math.round(metadata.height / 2) - 10 })
            .resize(640, 480)
            .min()
            .toBuffer()
            .then(outputBuffer => {
              return outputBuffer.toString('base64');
            })
        );
      }

      return Promise.all(promises)
    })
    .then(bothimages => {
      var requests = bothimages.map((image) => {
        return {
          features: [{ type: 'LABEL_DETECTION' }],
          image: { content: image }
        }
      })

      return client
        .batchAnnotateImages({ requests: requests })
    })
    .then(results => {
      // console.log(results[0].labelAnnotations);
      // console.log(results[1].labelAnnotations);
      // console.log(results);
      // console.log(results[0].responses[0].labelAnnotations);
      // console.log(results[0].responses[1].labelAnnotations);
      var allLabels = results[0].responses[0].labelAnnotations.concat(results[0].responses[1].labelAnnotations);
      
      successleft = false;
      successright = false;
      successleft = allLabels.some((label) => {
        console.log(label.description);
        return left == label.description;
      });

      successright = allLabels.some((label) => {
        // console.log(label.description);
        return right == label.description;
      });

      console.log(`leftword: ${left}`);
      console.log(`rightword: ${right}`);
   	  var result = successleft && successright;
    
      res.status(200).send({result: result});
    });

};
