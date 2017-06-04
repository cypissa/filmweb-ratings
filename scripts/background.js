chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Run the shit");
  chrome.tabs.query({active: true, currentWindow: true}, function(tabs){
    console.log(chrome.tabs);
    chrome.tabs.sendMessage(tabs[0].id, {action: "get-ratings"}, function(response) {});
  });
});
