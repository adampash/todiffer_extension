chrome.browserAction.onClicked.addListener (tab) ->
  console.log('Turning ' + tab.url + ' red!')
  chrome.tabs.insertCSS file: "styles/main.css", () ->
  chrome.tabs.executeScript file: "scripts/jquery.min.js", () ->
    chrome.tabs.executeScript file: "scripts/react.js", () ->
      chrome.tabs.executeScript
        file: 'scripts/submit_text.js'
