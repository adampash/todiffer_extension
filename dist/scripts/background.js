chrome.browserAction.onClicked.addListener(function(a){return console.log("Turning "+a.url+" red!"),chrome.tabs.insertCSS({file:"styles/main.css"},function(){}),chrome.tabs.executeScript({file:"scripts/jquery.min.js"},function(){return chrome.tabs.executeScript({file:"scripts/react.js"},function(){return chrome.tabs.executeScript({file:"scripts/submit_text.js"})})})});