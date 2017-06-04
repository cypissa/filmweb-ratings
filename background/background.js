console.log("DUPA");

chrome.browserAction.onClicked.addListener(function(tab) {
  console.log("Here we go, we have a click");
  var i = 1;
  chrome.extension.currentTab.postMessage("get-ratings");
});
