TXT_FETCH_API = "https://text-fetch.herokuapp.com"
TO_DIFFER_API = "//localhost:3000/texts"
LOADER = chrome.extension.getURL("images/loader.gif")

DiffSubmitter = React.createClass
  getInitialState: ->
    {
      status: 'initial'
      header_text: 'Looking for text...'
      text: ''
      title: ''
      loading: true
      url: window.location.href
      selector: null
    }
  handleResponse: (response) ->
    console.log response
    @setState
      status: 'confirm'
      header_text: 'Is this what you want to track?'
      text: response.text
      title: response.title
      url: response.url
      loading: false
  confirm: (params) ->
    @setState
      loading: true
      header_text: 'Saving...'
      status: 'saving'
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
          loading: false
        @cleanup()
      error: (err) =>
        console.log err
        @setState
          status: "error"
          header_text: "Something went wrong saving the text."
          loading: false
        @cleanup()
  cleanup: ->
    setTimeout ->
      $('#todiffer_overlay').fadeOut ->
        @remove()
    , 2500
  useSelector: ->
    @setState
      status: "selector"
      header_text: "Select the area containing the text you want to track."
    Selectable.init (selector) =>
      @setState
        selector: selector
        header_text: 'Looking for text...'
      @fetchText()
  fetchText: ->
    @setState
      loading: true
    params =
      url: @state.url
      selector: @state.selector
    $.ajax
      method: "POST"
      url: TXT_FETCH_API
      data: params
      success: (response) =>
        @handleResponse(response)
      error: (err) =>
        console.log err
        @setState
          status: "error"
          header_text: "Something went wrong fetching the text."
          loading: false
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
        loading={@state.loading}
      />
    </div>

ResultText = React.createClass
  render: ->
    unless @props.status is 'confirm'
      <div></div>
    else
      <div className="result">
        <div className="container">
          <h4>{@props.title}</h4>
          <div className="text"
            dangerouslySetInnerHTML={{
            __html: @props.text
            }}
          />
        </div>
      </div>


Header = React.createClass
  handleYes: ->
    @props.confirm()
  handleNo: ->
    @props.useSelector()
  render: ->
    <div className="status">
      <h4>{@props.text}</h4>
      <img src={LOADER}
        className={if @props.loading then '' else 'hide'}
      />
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
      return if $el.parents('#todiffer_overlay').length
      if (prevElement!= null)
        prevElement.classList.remove("mouseOn")
      elem.classList.add("mouseOn")
      prevElement = elem

    $(document).on 'click', (e) =>
      @elementChosen(e)
      false

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
