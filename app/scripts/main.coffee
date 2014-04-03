class Ascii
  constructor: (@img) ->
    MAX_WIDTH = 150
    line      = ''
    W         = if @img.width > MAX_WIDTH then MAX_WIDTH else @img.width
    H         = if @img.width > MAX_WIDTH then @img.height * MAX_WIDTH / @img.width else @img.height
    tcanvas   = document.createElement 'canvas'
    ascii     = document.getElementById 'ascii'

    ascii.classList.remove 'hidden'
    ascii.innerHTML = ''

    tcanvas.width   = W
    tcanvas.height  = H

    tc = tcanvas.getContext '2d'
    tc.fillStyle = 'white'
    tc.fillRect 0, 0, W, H

    tc.drawImage @img, 0, 0, W, H

    pixels = tc.getImageData 0, 0, W, H
    colordata = pixels.data

    for color, i in colordata by 4
      r = colordata[i]
      g = colordata[i + 1]
      b = colordata[i + 2]

      gray = r * 0.2126 + g * 0.7152 + b * 0.0722

      colordata[i] = colordata[i + 1] = colordata[i + 2] = gray

      if gray > 250
        character = '&nbsp;' # almost white
      else if gray > 230
        character = '`'
      else if gray > 200
        character = ':'
      else if gray > 175
        character = '*'
      else if gray > 150
        character = '+'
      else if gray > 125
        character = '#'
      else if gray > 50
        character = 'W'
      else
        character = '@' # almost black

      # if the pointer reaches end of pixel-line
      if i isnt 0 && (i / 4) % W is 0
        ascii.innerHTML = ascii.innerHTML + line;
        # newline
        ascii.appendChild(document.createElement('br'));
        # emptying line for the next row of pixels.
        line = '';

      line += character;

class File
  constructor: ->
    @elm = document.getElementById 'uploadImg'
    _self = @

    if @elm.addEventListener
      @elm.addEventListener 'dragover', @handleDragOver, false
      @elm.addEventListener 'dragleave', @handleDragLeave, false
      @elm.addEventListener 'drop', (e) ->
        _self.handleFileSelect e, _self
      , false
      @elm.addEventListener 'dragend', @handleDragEnd, false
    else if elm.attachEvent
      @elm.attachEvent 'ondragover', @handleDragOver
      @elm.attachEvent 'ondragleave', @handleDragLeave
      @elm.attachEvent 'ondrop', (e) ->
        _self.handleFileSelect e, _self
      @elm.attachEvent 'ondragend', @handleDragEnd

  handleDragOver: (e) ->
    e.preventDefault()
    e.target.classList.add 'dragover'

  handleDragLeave: (e) ->
    e.preventDefault()
    e.target.classList.remove 'dragover'

  handleDragEnd: (e) ->
    e.preventDefault()
    e.target.classList.remove 'dragover'

  handleFileSelect: (e, _self) ->
    e.preventDefault()

    files = e.dataTransfer.files

    for file in files
      do (file) ->
        # Only process image files.
        # if not file.type.match 'image.*'
        #   continue;

        reader = new FileReader()

        reader.onload = ((theFile) ->
          (e) ->
            link = document.createElement 'a'
            link.href = '#'
            link.innerHTML = ['<img class="img-thumbnail" src="', e.target.result, '"/>'].join('');
            document.getElementById('list').insertBefore link, null

            if link.addEventListener
              link.addEventListener 'click', (e) ->
                if this.className.match 'selected'
                  _self.unselect e, this
                else
                  _self.select e, this, this.getElementsByTagName('img')[0]
              , false;
            else if link.attachEvent
              link.attachEvent 'onclick', (e) ->
                if this.className.match 'selected'
                  _self.unselect e, this
                else
                  _self.select e, this, this.getElementsByTagName('img')[0]
              , false;
        )(file)

        reader.readAsDataURL(file)

  select: (e, elm, img) ->
    e.preventDefault()
    new Ascii img

  unselect: (e) ->
    e.preventDefault()
    element = elm || ''

new File()