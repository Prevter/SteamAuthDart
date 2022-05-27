library steam_auth;

class Confirmation {
  String id;
  String key;
  int intType;
  String creator;
  late ConfirmationType type;

  Confirmation(
      {required this.id,
      required this.key,
      required this.intType,
      required this.creator}) {
    switch (intType) {
      case 1:
        type = ConfirmationType.genericConfirmation;
        break;
      case 2:
        type = ConfirmationType.trade;
        break;
      case 3:
        type = ConfirmationType.marketSellTransaction;
        break;
      default:
        type = ConfirmationType.unknown;
    }
  }
}

class ConfirmationDetails {
  bool success;
  String html;

  ConfirmationDetails({required this.success, required this.html}) {
    html =
        '<!DOCTYPE html><html class="responsive touch legacy_mobile" lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1,user-scalable=no"><meta name="theme-color" content="#171a21"><title>Steam Community :: Confirmations</title><link rel="shortcut icon" href="/favicon.ico" type="image/x-icon"><link href="https://community.akamai.steamstatic.com/public/shared/css/motiva_sans.css?v=-DH0xTYpnVe2&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/shared/css/buttons.css?v=n-eRNszNIRMH&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/shared/css/shared_global.css?v=29MQRF5DS62e&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/css/globalv2.css?v=Tj_Gb074U72O&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/css/skin_1/modalContent.css?v=.TP5s6TzX6LLh" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/css/mobile/styles_mobileconf.css?v=7eOknd5U_Oiy&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/shared/css/motiva_sans.css?v=-DH0xTYpnVe2&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/css/skin_1/html5.css?v=.MtSlvoLZL0Tb" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/css/skin_1/economy.css?v=09AGT_Kww_HY&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/css/skin_1/trade.css?v=HdcFTfHh9VyM&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/css/skin_1/profile_tradeoffers.css?v=X4MCM7I71wwc&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/shared/css/shared_responsive.css?v=JwLwElgC5mGW&amp;l=english" rel="stylesheet" type="text/css"><link href="https://community.akamai.steamstatic.com/public/css/skin_1/header.css?v=g7VmRhGIDEiu&amp;l=english" rel="stylesheet" type="text/css"><script>!function(e,a,n,t,o,i,s){e.GoogleAnalyticsObject=o,e.ga=e.ga||function(){(e.ga.q=e.ga.q||[]).push(arguments)},e.ga.l=1*new Date,i=a.createElement(n),s=a.getElementsByTagName(n)[0],i.async=1,i.src="//www.google-analytics.com/analytics.js",s.parentNode.insertBefore(i,s)}(window,document,"script",0,"ga"),ga("create","UA-33779068-1","auto",{sampleRate:.4}),ga("set","dimension1",!0),ga("set","dimension2","Steam Mobile App"),ga("set","dimension3","mobileconf"),ga("set","dimension4","mobileconf/conf"),ga("send","pageview")</script><script type="text/javascript">var __PrototypePreserve=[];__PrototypePreserve[0]=Array.from,__PrototypePreserve[1]=Function.prototype.bind,__PrototypePreserve[2]=HTMLElement.prototype.scrollTo</script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/prototype-1.7.js?v=.55t44gwuwgvw"></script><script type="text/javascript">Array.from=__PrototypePreserve[0]||Array.from,Function.prototype.bind=__PrototypePreserve[1]||Function.prototype.bind,HTMLElement.prototype.scrollTo=__PrototypePreserve[2]||HTMLElement.prototype.scrollTo</script><script type="text/javascript">VALVE_PUBLIC_PATH="https://community.akamai.steamstatic.com/public/"</script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/scriptaculous/_combined.js?v=OeNIgrpEF8tL&amp;l=english&amp;load=effects,controls,slider,dragdrop"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/global.js?v=mNBniElLojkY&amp;l=english"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/jquery-1.11.1.min.js?v=.isFTSRckeNhC"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/shared/javascript/tooltip.js?v=.zYHOpI1L3Rt0"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/shared/javascript/shared_global.js?v=YFMMFQhfDiXj&amp;l=english"></script><script type="text/javascript">Object.seal&&[Object,Array,String,Number].map(function(e){Object.seal(e.prototype)})</script><script type="text/javascript">\$J=jQuery.noConflict(),"object"==typeof JSON&&JSON.stringify&&JSON.parse||document.write(\'<script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/json2.js?v=pmScf4470EZP&amp;l=english" ></script>\n\')</script><script type="text/javascript">document.addEventListener("DOMContentLoaded",function(t){SetupTooltips({tooltipCSSClass:"community_tooltip"})})</script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/jquery-ui-1.9.2.min.js?v=.ILEZTVPIP_6a"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/shared/javascript/mobileappapi.js?v=KX5d7WjziQ7F&amp;l=english&amp;mobileClientType=android"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/mobile/mobileconf.js?v=mzd_2xm8sUkb&amp;l=english"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/economy_common.js?v=tsXdRVB0yEaR&amp;l=english"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/economy.js?v=uSWx170LyQQO&amp;l=english"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/modalv2.js?v=dfMhuy-Lrpyo&amp;l=english"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/javascript/modalContent.js?v=WB1_7m5fDJMa&amp;l=english"></script><script type="text/javascript" src="https://community.akamai.steamstatic.com/public/shared/javascript/shared_responsive_adapter.js?v=6jtqzASUCYZw&amp;l=english"></script><meta name="twitter:card" content="summary_large_image"><meta name="twitter:site" content="@steam"><meta property="og:title" content="Steam Community :: Confirmations"><meta property="twitter:title" content="Steam Community :: Confirmations"><meta property="og:type" content="website"><meta property="fb:app_id" content="105386699540688"><link rel="image_src" href="https://community.akamai.steamstatic.com/public/shared/images/responsive/share_steam_logo.png"><meta property="og:image" content="https://community.akamai.steamstatic.com/public/shared/images/responsive/share_steam_logo.png"><meta name="twitter:image" content="https://community.akamai.steamstatic.com/public/shared/images/responsive/share_steam_logo.png"><meta property="og:image:secure" content="https://community.akamai.steamstatic.com/public/shared/images/responsive/share_steam_logo.png"><script type="text/javascript">\$J(function(){window.location="steammobile://settitle?title=Confirmations"})</script></head><body class="responsive_page">'
        '$html</body></html>';
  }
}

enum ConfirmationType {
  genericConfirmation,
  trade,
  marketSellTransaction,
  unknown
}
