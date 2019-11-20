# ISAPI filters solution for logging the original Client IP in Azure Web Apps (IIS).

[X-Forwarded-For](https://en.wikipedia.org/wiki/X-Forwarded-For) header logging is supported in Apache (with mod_proxy) but Microsoft IIS does not have a direct way to support the translation of the X-Forwarded-For value into the client ip (c-ip) header value that is used in its webserver logging as client IP address. This is true for Azure web apps' web server logging as it is IIS-based, hense I'd like to introduce how to log the original client ip using [f5-xforwarded-for](https://devcentral.f5.com/articles/x-forwarded-for-log-filter-for-windows-servers), an ISAPI Filter for IIS originated by F5. It can replace ISAPI c-ip value with X-Forwarding-For HTTP header.

##  Logging Client ip from the translation of X-Forwarded-For value

Web Apps can support the use of ISAPI Filters. The followings are files that need to be deployed and overall directory layout:

1. Deploy the DLL with your web app
2. Register the DLL using web.config
3. Place an applicationHost.xdt file in the site root 

```
D:\home\site\
          |
          + - applicationHost.xdt
          + - wwwroot\
                  |
                  + - ISAPIFilters/
                          + - F5XForwardedFor.dll
                          + - F5XForwardedFor.ini  (optional)
                  + - index.html
                  + - web.config
```

Once all files are deployed, restart the app and see if the original client IP is logged on webserver log! Here are sample logs and yellow highlighted part '192.172.0.1' is ISAPI c-ip value which was replaced by f5-xforwarded-for ISAPI filter.

![sample-webapp-log](https://github.com/yokawasa/azure-webapps-logging-original-clientip/raw/master/img/sample-webapps-log.png)

### 1. Deploy the DLL with your web app

First, download the F5XForwardedFor.dll (you need 32 bit version ) from [F5 site](https://cdn.f5.com/websites/devcentral.f5.com/downloads/F5XForwardedFor.zip) on your local directory. You can run download-F5XForwardedFor-dll.sh script that helps you to get copy of F5XForwardedFor.zip from F5 site and extract a 32 bit DLL onto ISAPIFilters directory from the package.

```
$ download-F5XForwardedFor-dll.sh
  -->>> ISAPIFilters/F5XForwardedFor.dll
```

Then, deploy F5XForwardedFor.dll wth your web app. In the example here, let's deploy the DLL onto D:\home\site\wwwroot\ISAPIFilters/F5XForwardedFor.dll

### 2. Register the DLL using web.config

Register F5XForwardedFor.dll as isapiFilters in web.config. Suppose you deploy the F5XForwardedFor.dll to the path, D:\home\site\wwwroot\ISAPIFilters\F5XForwardedFor.dll, add the the <isapiFilters> block in to web.config like this below. The <hiddenSegments> block in web.config below is for blocking an HTTP request to the F5XForwardedFor.dll.

```xml
<configuration>
    <system.webServer>
        <isapiFilters>
            <filter name="F5XForwardedFor" enabled="true" enableCache="false" path="D:\home\site\wwwroot\ISAPIFilters\F5XForwardedFor.dll"/>
        </isapiFilters>
        <security>
            <requestFiltering>
                <hiddenSegments>
                    <add segment="ISAPIFilters" />
                </hiddenSegments>
            </requestFiltering>
        </security>
    </system.webServer>
</configuration>
```

### 3. Place an applicationHost.xdt file in the site root

Deploy applicationHost.xdt file in the site root, which is needed to allow for ISAPI filters overriding parent level setting in IIS.

```xml
<?xml version="1.0"?>
<configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform">
<configSections>
    <sectionGroup name="system.webServer">
      <section name="isapiFilters" xdt:Transform="SetAttributes(overrideModeDefault)" overrideModeDefault="Allow" />
    </sectionGroup>
  </configSections>
</configuration>
```

## Logging Client ip from the translation of Custom HTTP header value

You can also log the original client ip from the translation of Custom HTTP header value instead of X-Forwarding-For. By default, the f5-xforwarded-for ISAPI filter replaces ISAPI c-ip value with X-Forwarding-For HTTP header, but you can configure F5XForwardedFor.ini in the same directory as the filter so as for the filter to replace ISAPI c-ip value with your customer header value. The .ini file's format is this below:

```
[SETTINGS]
HEADER=Custom-Header-Name
```

## Testing the configuration by sending sample HTTP requests

At last, test the configuration by sending sample HTTP requests with X-Forwarded-For header or your custom header. Here is a sample script that send dummy HTTP request with your customer header using curl. Hope it would help for your test.

```shell
HEADER_NAME="X-Forwarded-For"
#HEADER_NAME="Custom-Header-Name"
CLIENT_IP='192.168.0.1'
URL="http:///<appname>.azurewebsites.net"

curl -X GET -H "$HEADER_NAME: $CLIENT_IP" $URL
```
