{
  config,
  lib,
  pkgs,
  hostName,
  ...
}: let
  subnetInterface = "eth0";

  proxyHost = "172.19.144.1";
  proxyPort = "10808";

  # socksProxyUrl = "socks5h://${proxyHost}:${proxyPort}";
  httpProxyUrl = "http://${proxyHost}:${proxyPort}";

  noProxyTargets = [
    "localhost"
    "127.0.0.1"
    "::1"
    "10.0.0.0/8"
    "172.16.0.0/12"
    "192.168.0.0/16"
  ];
  noProxyString = builtins.concatStringsSep "," noProxyTargets;
in {
  networking.hostName = hostName;

  networking.firewall.trustedInterfaces = [subnetInterface];

  networking.proxy = {
    allProxy = httpProxyUrl;
    httpsProxy = httpProxyUrl;
    httpProxy = httpProxyUrl;
    ftpProxy = httpProxyUrl;
    noProxy = noProxyString;
  };
}
