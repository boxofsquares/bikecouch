/**
 * Responds to any HTTP request.
 *
 * @param {!Object} req HTTP request context.
 * @param {!Object} res HTTP response context.
 */

const vision = require('@google-cloud/vision').v1p3beta1;
const sharp = require('sharp');

const client = new vision.ImageAnnotatorClient();

var Logger = {
  message: ":::LOG DUMP:::\n",
  log: function(message) {
    this.message += message + '\n';
  },
  flush: function() {
    console.log(this.message);
    this.message = ":::LOG DUMP:::\n";
  },
  error: function(error) {
    this.message += '\n:::ERROR:::\n' + error + '\n';
    this.flush();
    res.status(400).send();
  }
}

exports.labelDetection = (req, res) => {
  // Challenge words for this request
  let challengeWords = JSON.parse(req.body.challengeWords);
  // The base64 image string
  let b64image = req.body.image;
  // decode the string into a int buffer
  let imgBuffer = Buffer.from(b64image, 'base64');
  // The focus anchors (user selection)
  let anchors = JSON.parse(req.body.anchors);

  // Initialize Sharp object
  const image = sharp(imgBuffer);
  image
    .metadata()
    .then(metadata => {
      // Checking Image dimensions
      Logger.log(`Image Metadata | width: ${metadata.width} & height: ${metadata.height}`);

      var promises = anchors.map((focusAnchor, index) => {
        let dx; // x offset
        let dy; // y offset
        let w;  // width
        let h;  // height
        
        // iOs: Height of phone is width of 
        if (metadata.width > metadata.height) {
          dx = Math.floor(focusAnchor['dy_offset'] * metadata.width) - 1;
          dy = Math.floor((1 - focusAnchor['dx_offset'] - focusAnchor['width']) * metadata.height) - 1;
          w = Math.floor(Math.min(focusAnchor['height'] * metadata.width - 1, metadata.width - dx - 1));
          h = Math.floor(Math.min(focusAnchor['width'] * metadata.height - 1, metadata.height - dy - 1));
        } else { // Android: Height of phone is height of image
          dx = Math.floor(focusAnchor['dx_offset'] * metadata.width) - 1;
          dy = Math.floor(focusAnchor['dy_offset'] * metadata.height) - 1;
          w = Math.floor(Math.min(focusAnchor['width'] * metadata.width - 1, metadata.width - dx - 1));
          h = Math.floor(Math.min(focusAnchor['height'] * metadata.height - 1, metadata.height - dy - 1));
        }

        // Checking crop dimensions
        Logger.log(`Crop Details ${challengeWords[index].toUpperCase()}: dx: ${dx} | dy: ${dy} | w: ${w} | h: ${h}`);
        return image
          // image must be cloned for each independent operation on it
          .clone()
          .extract({
            left: dx,
            top: dy,
            width: w,
            height: h,
          })
          .resize(640, 480)
          .min()
          .toBuffer()
          .then(outputBuffer => {
            return outputBuffer.toString('base64');
          });
      });
      return Promise.all(promises)
    })
    .catch((error) => {
      Logger.error("ERROR extracting and resizing.")
    })
    .then(allRequests => {
      var requests = allRequests.map((image) => {
        return {
          features: [{
            type: 'LABEL_DETECTION'
          }],
          image: {
            content: image
          }
        }
      });

      return client
        .batchAnnotateImages({
          requests: requests
        });
    })
    .catch((error) => {
      Logger.error("ERROR sending annotation requests.")
    })
    .then(results => {
      let allResponses = results[0].responses;
      let failure = allResponses.some((response, index) => {
        let allLabels = response.labelAnnotations.map((ann) => { return ann.description});
        Logger.log(`Labels for box ${challengeWords[index].toUpperCase()}: ${allLabels.join(" | ")}`);
        return !allLabels.includes(challengeWords[index]);
      });
      Logger.flush();
      res.status(200).send({
        result: !failure
      });

    })
    .catch((error) => {
      Logger.error("ERROR processing labels.");
    });
};