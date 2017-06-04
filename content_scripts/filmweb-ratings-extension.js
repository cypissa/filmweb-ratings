function getRate(html)
{
  var e = $($(html).find(".filmRateBox")[0].innerHTML).find("span[itemprop='ratingValue'");

  if (e[0] !== undefined) {
    return e[0].innerHTML.trim();
  }

  return null;
}

function getVotes(html)
{
  var e = $($(html).find(".filmRateBox")[0].innerHTML).find("span[itemprop='ratingCount'");

  if (e[0] !== undefined) {
    return e[0].innerHTML.trim();
  }

  return null;
}

function httpGet(addr, link)
{
  $.get(addr, function(data) {
      var rate = getRate(data),
          votes = getVotes(data),
          voteSize="14px";

      if (rate && votes) {
        if (parseInt(rate) >= 7) {
          voteSize="20px";
        }
        $(link).append(
          " <span style=\"color: blue; font-weight:bold; font-size:"+voteSize+";\">" + rate + "</span>" +
          " <span style=\"color: yellow; font-weight:bold; font-size:12px;\">(" + votes + ")</span>"
        );
      } else {
        $(link).append(" <span style=\"color: red; font-weight:bold;\"> ]:-) </span>");
      }
  });
}

function getRates()
{
  var a = $(".link.s-16");
  var rate;

  a.each(function(i, link) {
      httpGet(link.href, link);
  });
}

chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
  if (request.action == 'get-ratings') {
      getRates();
  }
});
