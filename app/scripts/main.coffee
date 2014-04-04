$.event.props.push "dataTransfer"

class Ascii
  constructor: (@img) ->
    MAX_WIDTH = 100
    line      = ''
    W         = if @img.width > MAX_WIDTH then MAX_WIDTH else @img.width
    H         = if @img.width > MAX_WIDTH then @img.height * MAX_WIDTH / @img.width else @img.height
    tcanvas   = document.createElement 'canvas'
    ascii     = $('#ascii')

    ascii.html ''
    ascii.removeClass 'hidden'

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
        ascii.html ascii.html() + line
        # newline
        ascii.append('<br>')
        # emptying line for the next row of pixels.
        line = ''

      line += character

class File
  constructor: ->
    @elm = $('#uploadImg')
    _self = @

    $(@elm).on 'dragover', @handleDragOver
    $(@elm).on 'dragleave', @handleDragLeave
    $(@elm).on 'drop', (e) ->
      _self.handleFileSelect e, _self

  handleDragOver: (e) ->
    e.preventDefault()
    $(e.target).addClass 'dragover'

  handleDragLeave: (e) ->
    e.preventDefault()
    $(e.target).removeClass 'dragover'

  handleFileSelect: (e, _self) ->
    e.preventDefault()

    $(e.target).removeClass 'dragover'
    $('#list').removeClass 'hidden'
    $('#btns').removeClass 'hidden'

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
            $('#list').append link

            $(link).on 'click', (e) ->
              new Ascii this.getElementsByTagName('img')[0]
        )(file)

        reader.readAsDataURL(file)

$(window).scroll ->
  if $('body').scrollTop() > 1030
    $('#another').removeClass 'hidden'
  else
    $('#another').addClass 'hidden'

$('.select').on 'click', (e) ->
  e.preventDefault()
  text = document.getElementById 'ascii'
  if document.body.createTextRange
    range = document.body.createTextRange()
    range.moveToElementText text
    range.select()
  else if window.getSelection
    selection = window.getSelection()
    range = document.createRange()
    range.selectNodeContents text
    selection.removeAllRanges()
    selection.addRange range

$('.reset').on 'click', (e) ->
  e.preventDefault()
  $('body').animate
    scrollTop: 0
  , 500, ->
    $('#list').addClass('hidden').find('a').remove()
    $('#btns').addClass('hidden')
    $('#ascii').html('').addClass('hidden')

new File()