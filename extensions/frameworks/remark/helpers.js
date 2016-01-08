
yaml = require('js-yaml');

module.exports = {
  slideProcessors: [
    function(slide, globals){
      Object.keys(globals).forEach(function(key){
        slide.attributes[key] = globals[key];
      });
    }
  ],
  showHelpers: {
    slidewinder: function(context){
      slideData = context.data.root;
      var bodies = slideData.slides.map(function(slide) {
        completeBody = yaml.dump(slide.attributes) + '\n' + slide.body
        return completeBody;
      });
      bodies.join('\n---\n');
      return bodies.join('\n---\n');
    }
  }
}
