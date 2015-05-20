TXT_FETCH_API = "https://text-fetch.herokuapp.com"
TO_DIFFER_API = "http://localhost:3000/texts"

DiffSubmitter = React.createClass
  getInitialState: ->
    {
      status: 'initial'
      header_text: 'Submitting...'
      text: ''
      title: ''
      url: window.location.href
      selector: null
    }
  handleResponse: (response) ->
    console.log response
    @setState
      status: 'confirm'
      header_text: 'Is this the text you want to track?'
      text: response.text
      title: response.title
  confirm: (params) ->
    params =
      text:
        url: @state.url
        selector: @state.selector
    $.ajax
      method: "POST"
      url: TO_DIFFER_API
      data: params
      success: (response) =>
        @setState
          status: "done"
          header_text: "Tracking text."
        setTimeout ->
          $('#todiffer_overlay').fadeOut ->
            @remove()
        , 2500
      error: (err) ->
        debugger
  useSelector: ->
    @setState
      status: "selector"
      header_text: "Select the area containing the text you want to track."
    Selectable.init (selector) =>
      @setState
        selector: selector
      @fetchText()
  fetchText: ->
    params =
      url: @state.url
      selector: @state.selector
    $.ajax
      method: "POST"
      url: TXT_FETCH_API
      data: params
      success: (response) =>
        @handleResponse(response)
      error: (err) ->
        debugger
  componentDidMount: ->
    @fetchText()
  render: ->
    <div>
      <ResultText
        text={@state.text}
        title={@state.title}
        status={@state.status}
      />
      <Header
        text={@state.header_text}
        status={@state.status}
        confirm={@confirm}
        useSelector={@useSelector}
      />
    </div>

ResultText = React.createClass
  render: ->
    unless @props.status is 'confirm'
      <div></div>
    else
      <div className="result">
        <h4>{@props.title}</h4>
        <div className="text"
          dangerouslySetInnerHTML={{
          __html: @props.text
          }}
        />
      </div>


Header = React.createClass
  handleYes: ->
    @props.confirm()
  handleNo: ->
    @props.useSelector()
  render: ->
    <div className="status">
      <h4>{@props.text}</h4>
      <div className={
        "confirmation #{if @props.status is 'confirm' then '' else 'hide'}"
      }>
        <button onClick={@handleYes}>Yes</button>
        <button onClick={@handleNo}>No</button>
      </div>
    </div>

$('body').prepend('<div id="todiffer_overlay"></div>')

React.render(
  <DiffSubmitter />,
  document.getElementById('todiffer_overlay')
)


Selectable =
  init: (callback) ->
    @callback = callback
    prevElement = null
    $(document).on 'mousemove', (e) ->
      elem = e.target || e.srcElement
      $el = $(elem)
      if (prevElement!= null)
        prevElement.classList.remove("mouseOn")
      elem.classList.add("mouseOn")
      prevElement = elem

    $(document).on 'click', (e) =>
      @elementChosen(e)

  elementChosen: (e) ->
    $(document).off 'mousemove'
    $(document).off 'click'
    # document.removeEventListener('click', elementChosen)
    elem = e.target || e.srcElement
    selectors = @getSelectors(elem).replace(/\.+/g, '.')
    @callback selectors

  getSelectors: (el) ->
    $el = $(el)
    selector = ""
    # comment out if I want full path
    selector += $el.parents()
                .map () -> @tagName.toLowerCase()
                .get().reverse().join(" ")

    if selector
      selector += " "+ $el[0].nodeName.toLowerCase()

    id = $el.attr("id")
    if id
      selector += "#"+ id

    classNames = $el.attr("class")
    if (classNames)
      selector += "." + $.trim(classNames).replace(/\s/gi, ".")

    selector = selector.replace('.mouseOn', '')
    selector
