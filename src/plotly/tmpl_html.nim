proc removeComments(a: string): string=
  ## removes lines starting with `#` (convenient; avoids having to use html comments when making edits)
  for a in a.splitLines:
    if a.strip.startsWith "#": continue
    result.add a & "\n"

const defaultTmplString = """
<!DOCTYPE html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>$title</title>
     <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
  </head>
  <body>
    <div id="plot0"></div>
    <script>
        # TODO: this currently overrides size settings given in plots;
        # need to expose whether to autoresize or not
        # Note: this didn't seem to work: Plotly.Plots.resize('plot0');
        runRelayout = function() {
          var margin = 50; // if 0, would introduce scrolling
          Plotly.relayout('plot0', {width: window.innerWidth - margin, height: window.innerHeight - margin } );
        };
        window.onresize = runRelayout;
       # Consider: {responsive: true}
       Plotly.newPlot('plot0', $data, $layout).then(runRelayout);
    </script>
    $saveImage
  </body>
</html>
""".removeComments

# type needs to be inserted!
# either
# - png
# - svg
# - jpg
const injectImageCode = """
<script>
        var d3 = Plotly.d3;
        var imageData;
        var img = d3.select('#$1-export');
        Plotly.toImage(plot0, {format: '$2', width: $3, height: $4}).then(function(url){
                img.attr("src", url);
                imageData = url;
                return Plotly.toImage(plot0,{format:'$5', width: $6, height: $7});
              })
        var connection = new WebSocket('ws://localhost:8080');
        // after connection opened successfully, send our image
        connection.onopen = function() {
          // need to wait a short while to be sure the promise is fullfilled (I believe?!)
          connection.send("connected")
          setTimeout(function(){ connection.send(imageData); }, 100);
        };
</script>
"""

